//
//  DDService+Network.m
//
//  Created by Pan,Dedong
//  Version 1.1.0

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

#import "DDService+Network.h"
#import <objc/message.h>

NSString *const DDServiceURLKey = @"DDServiceURLKey";
NSString *const DDServiceOriginalURLKey = @"DDServiceOriginalURLKey";
NSString *const DDServiceHTTPMethodKey = @"DDServiceHTTPMethodKey";
NSString *const DDServiceHTTPMethodGet = @"GET";
NSString *const DDServiceHTTPMethodPost = @"POST";

NSString *const DDServiceHeaderKey = @"DDServiceHeaderKey";

NSString *const DDServiceGetParametersKey = @"DDServiceGetParametersKey";
NSString *const DDServicePostParametersKey = @"DDServicePostParametersKey";

NSString *const DDServiceContentTypeKey = @"DDServiceContentTypeKey";
NSString *const DDServiceRequestBodyKey = @"DDServiceRequestBodyKey";

NSString *const DDServiceMutipartFormKey = @"DDServiceMutipartFormKey";
NSString *const DDServiceFormDataKey = @"DDServiceFormDataKey";
NSString *const DDServiceFormNameKey = @"DDServiceFormNameKey";
NSString *const DDServiceFormFileNameKey = @"DDServiceFormFileNameKey";
NSString *const DDServiceFormContentTypeKey = @"DDServiceFormContentTypeKey";

NSString *const DDServiceRequestKey = @"DDServiceRequestKey";
NSString *const DDServiceResponseKey = @"DDServiceResponseKey";
NSString *const DDServiceErrorKey = @"DDServiceErrorKey";

static NSString *WMURLServiceCreateStringByAddingPercentEscapes(NSString *string) {
    NSString *resultString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return resultString;
}

static NSString *DDServiceAssembleParameterString(NSDictionary *parameters) {
    NSMutableArray *parameterArray = [NSMutableArray array];
    for (id key in parameters.allKeys) {
        NSString *encodingKey = WMURLServiceCreateStringByAddingPercentEscapes([key description]);
        NSString *encodingValue = WMURLServiceCreateStringByAddingPercentEscapes([parameters[key] description]);
        [parameterArray addObject:[NSString stringWithFormat:@"%@=%@", encodingKey, encodingValue]];
    }
    return (parameterArray.count > 0)? [parameterArray componentsJoinedByString:@"&"]: @"";
}

static NSString *DDServiceAssembleURLString(NSString *originalUrl, NSDictionary *getParameters) {
    if (getParameters.count == 0) { return originalUrl; }
    NSString *joinerFlag = ([originalUrl rangeOfString:@"?"].length > 0)? @"&": @"?";
    return [originalUrl stringByAppendingFormat:@"%@%@",joinerFlag, DDServiceAssembleParameterString(getParameters)];
}

static NSURLRequest *DDServiceAssembleURLRequest(DDService *service) {
    NSString *urlString = DDServiceAssembleURLString(service.parameters[DDServiceURLKey], service.parameters[DDServiceGetParametersKey]);
    
    NSDictionary *postParameters = service.parameters[DDServicePostParametersKey];
    NSString *contentType = service.parameters[DDServiceContentTypeKey];
    NSString *requestBody = service.parameters[DDServiceRequestBodyKey];
    NSArray *mutipartFormData = service.parameters[DDServiceMutipartFormKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = (postParameters.count > 0 || requestBody.length > 0 || mutipartFormData)? DDServiceHTTPMethodPost: service.parameters[DDServiceHTTPMethodKey]?: DDServiceHTTPMethodGet;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.timeoutInterval = 18;
    [request setAllHTTPHeaderFields:service.parameters[DDServiceHeaderKey]?: @{}];
    
    if (postParameters.count > 0 || mutipartFormData.count) {
        if (mutipartFormData.count == 0) {
            request.HTTPBody = [DDServiceAssembleParameterString(postParameters) dataUsingEncoding:NSUTF8StringEncoding];
        }
        else {
            NSMutableData *requestData = [NSMutableData data];
            
            NSString *boundary = @"D3JKIOU8743NMNFQWERTYUIO12345678BNM";
            NSString *mutiPartBoundary = [NSString stringWithFormat:@"--%@",boundary];
            NSString *endMutiPartBoundary = [NSString stringWithFormat:@"%@--",mutiPartBoundary];
            
            //content
            NSMutableString *body = [NSMutableString stringWithCapacity:0];
            for (NSString *key in postParameters.allKeys) {
                [body appendFormat:@"%@\r\n",mutiPartBoundary];
                [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
                [body appendFormat:@"%@\r\n",[postParameters objectForKey:key]];
                
            }
            [requestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
            
            //file
            NSArray *mutipartForm = service.parameters[DDServiceMutipartFormKey];
            int i = 0;
            for (NSDictionary *formData in mutipartForm) {
                NSMutableString *fileBody = [NSMutableString stringWithCapacity:0];
                if (i == 0) {
                    [fileBody appendFormat:@"%@\r\n",mutiPartBoundary];
                }
                else {
                    [fileBody appendFormat:@"\r\n%@\r\n",mutiPartBoundary];
                }
                
                [fileBody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", formData[DDServiceFormNameKey], formData[DDServiceFormFileNameKey]];
                [fileBody appendFormat:@"Content-Type: %@\r\n\r\n", formData[DDServiceFormContentTypeKey]];
                [requestData appendData:[fileBody dataUsingEncoding:NSUTF8StringEncoding]];
                [requestData appendData:formData[DDServiceFormDataKey]];
                i ++;
            }
            
            //end
            [requestData appendData:[[NSString stringWithFormat:@"\r\n%@",endMutiPartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
            [request setValue:@(requestData.length).stringValue forHTTPHeaderField:@"Content-Length"];
            request.HTTPBody = requestData;
        }
    }
    else if (requestBody.length > 0) {
        if (contentType.length > 0) {[request setValue:contentType forHTTPHeaderField:@"Content-Type"]; }
        request.HTTPBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
}

@interface DDServiceNetworkProxy : NSObject

@property (strong, nonatomic) DDService *service;
@property (strong, nonatomic) DDService *rootService;
@property (strong, nonatomic) NSURLSessionTask *task;

- (instancetype)initWithService:(DDService *)service;

- (void)sendRequest;

@end

@implementation DDServiceNetworkProxy

- (void)dealloc {
    [_rootService removeObserver:self forKeyPath:@"wantCancel"];
}

- (instancetype)initWithService:(DDService *)service {
    if (self = [super init]) {
        self.service = service;
    }
    return self;
}

- (void)setService:(DDService *)service {
    _service = service;
    if (_rootService) { [_rootService removeObserver:self forKeyPath:@"wantCancel"]; }
    _rootService = service;
    while ([_rootService valueForKey:@"parentService"]) { _rootService = [_rootService valueForKey:@"parentService"]; }
    [_rootService addObserver:self forKeyPath:@"wantCancel" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)sendRequest {
    DDService *service = _service;
    NSURLRequest *request = DDServiceAssembleURLRequest(service);
#ifdef DEBUG
    NSLog(@"\n*************WMURLService.sendRequest(%@):\n%@\n*************\n",request.HTTPMethod, request.URL);
#endif
    
    __block NSError *responseError = nil;
    __block NSData *responseData = nil;
    __block NSURLResponse *urlResponse = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                 {
                     responseData = data;
                     responseError = error;
                     urlResponse = response;
                     dispatch_semaphore_signal(semaphore);
                 }];
    [self.task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (responseError) {
        service.result = @{ DDServiceErrorKey: responseError };
        [service failedWithMsg:@"网络请求失败"];
    }
    else {
        service.result = @{ DDServiceRequestKey: request, DDServiceResponseKey: urlResponse, DDServiceResultKey: responseData };
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"wantCancel"]) { return; }
    BOOL wantCancel = [[object valueForKey:@"wantCancel"] boolValue];
    if (wantCancel) { [self.task cancel]; }
}

@end

@implementation DDService (Network)

+ (void)sendURLRequest:(DDService *)service {
    NSAssert(service.parameters[DDServiceURLKey], @"url can not be nil");
    DDServiceNetworkProxy *proxy = [[DDServiceNetworkProxy alloc] initWithService:service];
    [proxy sendRequest];
}

@end
