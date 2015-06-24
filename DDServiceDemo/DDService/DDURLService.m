//
//  DDURLService.m
//
//  Created by Pan,Dedong
//  Version 1.0.0

//  This code is distributed under the terms and conditions of the MIT license.

//  Copyright (c) 2013 Pan,Dedong <dedong.pan@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "DDURLService.h"

NSString *const DDURLServiceURLKey = @"DDURLServiceURL";
NSString *const DDURLServicePostParametersKey = @"DDURLServicePostParameters";
NSString *const DDURLServiceGetParametersKey = @"DDURLServiceGetParameters";

NSString *const DDURLServiceFilesArrayKey = @"DDURLServiceFilesArray";
NSString *const DDURLServiceFileDataKey = @"DDURLServiceFileData";
NSString *const DDURLServiceFileFormNameKey = @"DDURLServiceFileFormName";
NSString *const DDURLServiceFileFileNameKey = @"DDURLServiceFileFileName";
NSString *const DDURLServiceFileContentTypeKey = @"DDURLServiceFileContentType";

static NSString *const DDURLServiceHTTPMethodGet = @"GET";
static NSString *const DDURLServiceHTTPMethodPost = @"POST";

static NSString *DDURLServiceCreateStringByAddingPercentEscapes(NSString *string) {
    CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef resultStringRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)string,
                                                                          NULL,
                                                                          CFSTR("!*'();:@&=+$,/?%#[]~"),
                                                                          cfStringEncoding);
    return (NSString *)CFBridgingRelease(resultStringRef);
}

static NSString *DDURLServiceAssembleParameterString(NSDictionary *parameters) {
    NSMutableArray *parameterArray = [NSMutableArray array];
    for (id key in parameters.allKeys) {
        NSString *encodingKey = DDURLServiceCreateStringByAddingPercentEscapes([key description]);
        NSString *encodingValue = DDURLServiceCreateStringByAddingPercentEscapes([parameters[key] description]);
        [parameterArray addObject:[NSString stringWithFormat:@"%@=%@", encodingKey, encodingValue]];
    }
    return [parameterArray componentsJoinedByString:@"&"];
}

@implementation DDURLService

+ (void)sendRequest:(DDService *)service
{
    NSString *urlString = service.parameters[DDURLServiceURLKey];
    NSAssert(urlString, @"url can not be nil");
    
    NSString *requestMethod = DDURLServiceHTTPMethodGet;

    NSDictionary *getParameters = service.parameters[DDURLServiceGetParametersKey];
    NSDictionary *postParameters = service.parameters[DDURLServicePostParametersKey];
    
    NSString *getParameterString = DDURLServiceAssembleParameterString(getParameters);
    NSString *postParameterString = DDURLServiceAssembleParameterString(postParameters);
    
    urlString = (getParameterString.length > 0) ? [urlString stringByAppendingFormat:@"?%@",getParameterString] : urlString;
    requestMethod = (postParameterString.length > 0) ? DDURLServiceHTTPMethodPost : DDURLServiceHTTPMethodGet;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
#ifdef DEBUG
    NSLog(@"\n*************DDURLService.sendRequest(%@):\n%@\n*************\n",requestMethod,url);
#endif
    
    [request setHTTPMethod:requestMethod];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:18];
    if (postParameterString.length > 0) [request setHTTPBody:[postParameterString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        service.result = @{DDServiceResultKey: error};
        [service failedWithMsg:error.domain];
    }
    else {
        service.result = @{DDServiceResultKey: returnData};
    }
}

+ (void)sendMultiPartFormRequest:(DDService *)service {
    NSString *urlString = service.parameters[DDURLServiceURLKey];
    NSAssert(urlString, @"url can not be nil");
    
    NSDictionary *getParameters = service.parameters[DDURLServiceGetParametersKey];
    NSString *getParameterString = DDURLServiceAssembleParameterString(getParameters);
    urlString = (getParameterString.length > 0) ? [NSString stringWithFormat:@"%@?%@", urlString, getParameterString] : urlString;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:DDURLServiceHTTPMethodPost];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:18];
    
    NSString *boundary = @"D3JKIOU8743NMNFQWERTYUIO12345678BNM";
    NSString *mutiPartBoundary = [NSString stringWithFormat:@"--%@",boundary];
    NSString *endMutiPartBoundary = [NSString stringWithFormat:@"%@--",mutiPartBoundary];
    
    NSMutableData *requestData = [NSMutableData data];
    
    //content
    NSDictionary *postParameters = service.parameters[DDURLServicePostParametersKey];
    NSMutableString *body = [NSMutableString stringWithCapacity:0];
    for (NSString *key in postParameters.allKeys) {
        [body appendFormat:@"%@\r\n",mutiPartBoundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[postParameters objectForKey:key]];
        
    }
    [requestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //file
    NSArray *fileArray = service.parameters[DDURLServiceFilesArrayKey];
    int i = 0;
    for (NSDictionary *fileDict in fileArray) {
        NSMutableString *fileBody = [NSMutableString stringWithCapacity:0];
        if (i == 0) {
            [fileBody appendFormat:@"%@\r\n",mutiPartBoundary];
        }
        else {
            [fileBody appendFormat:@"\r\n%@\r\n",mutiPartBoundary];
        }
        
        [fileBody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileDict[DDURLServiceFileFormNameKey], fileDict[DDURLServiceFileFileNameKey]];
        [fileBody appendFormat:@"Content-Type: %@\r\n\r\n", fileDict[DDURLServiceFileContentTypeKey]];
        [requestData appendData:[fileBody dataUsingEncoding:NSUTF8StringEncoding]];
        [requestData appendData:fileDict[DDURLServiceFileDataKey]];
        i ++;
    }

    //end
    [requestData appendData:[[NSString stringWithFormat:@"\r\n%@",endMutiPartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSError* error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil
                                                           error:&error];
    if (error) {
        service.result = @{DDServiceResultKey: error};
        [service failedWithMsg:error.domain];
    }
    else {
        service.result = @{DDServiceResultKey : returnData};
    }
}

@end
