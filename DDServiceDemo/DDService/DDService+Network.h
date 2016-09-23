//
//  DDService+Network.h
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

#import "DDService.h"

FOUNDATION_EXPORT NSString *const DDServiceURLKey;
FOUNDATION_EXPORT NSString *const DDServiceHTTPMethodKey;
FOUNDATION_EXPORT NSString *const DDServiceHTTPMethodGet;
FOUNDATION_EXPORT NSString *const DDServiceHTTPMethodPost;

FOUNDATION_EXPORT NSString *const DDServiceHeaderKey;

FOUNDATION_EXPORT NSString *const DDServiceGetParametersKey;
FOUNDATION_EXPORT NSString *const DDServicePostParametersKey;

FOUNDATION_EXPORT NSString *const DDServiceContentTypeKey;
FOUNDATION_EXPORT NSString *const DDServiceRequestBodyKey;

FOUNDATION_EXPORT NSString *const DDServiceMutipartFormKey;
FOUNDATION_EXPORT NSString *const DDServiceFormDataKey;
FOUNDATION_EXPORT NSString *const DDServiceFormNameKey;
FOUNDATION_EXPORT NSString *const DDServiceFormFileNameKey;
FOUNDATION_EXPORT NSString *const DDServiceFormContentTypeKey;

FOUNDATION_EXPORT NSString *const DDServiceRequestKey;
FOUNDATION_EXPORT NSString *const DDServiceResponseKey;
FOUNDATION_EXPORT NSString *const DDServiceErrorKey;

@interface DDService (Network)

/*! 根据相关参数发送请求
 *
 * @param Require <NSString *> parameters[DDServiceURLKey] 请求的 url。
 *
 * @param Option <NSString *> parameters[DDServiceHTTPMethodKey] GET/POST，默认为 GET，如果有POST参数则为 POST。
 *
 * @param Option <NSString *> parameters[DDServiceHeaderKey] request header。
 *
 * @param Option <NSDictionary *> parameters[DDServiceGetParametersKey]: GET参数 { "key" : "value", "key" : "value" ……}。
 *
 * @param Option <NSDictionary *> parameters[DDServicePostParametersKey]: POST参数 { "key" : "value", "key" : "value" ……}。如果传入该参数或传入 mutipartData 则会忽略 ContentType、RequestBody。
 *
 * @param Option <NSString *> parameters[DDServiceContentTypeKey]: 默认 application/x-www-form-urlencoded。
 *
 * @param Option <NSString *> parameters[DDServiceRequestBodyKey]: requestBody字符串，如果传入该参数会忽略 MutipartForm。
 *
 * @param Option <NSArray *> parameters[DDServiceMutipartFormKey]: 要提交的文件数组 NSArray 类型 [formData1, formData2 ……]
 * formData:\n { "DDServiceFormDataKey": <NSData *> 要提交的文件, "DDServiceFormNameKey": <NSString *> 表单名, "DDServiceFormFileNameKey": <NSString *> 文件名, "DDServiceFormContentTypeKey": <NSString *> 文件类型 image/jpeg }
 *
 * @result Require <NSURLResponse *> result[DDServiceResponseKey]: 请求的response
 * @result Option <NSData *> result[DDServiceResultKey]: 请求返回的数据
 * @result Option <NSError *> result[DDServiceErrorKey]: 请求失败的error
 */

+ (void)sendURLRequest:(DDService *)service;

@end
