//
//  DDURLService.h
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

#import <Foundation/Foundation.h>
#import "DDService.h"

FOUNDATION_EXPORT NSString *const DDURLServiceURLKey;
FOUNDATION_EXPORT NSString *const DDURLServicePostParametersKey;
FOUNDATION_EXPORT NSString *const DDURLServiceGetParametersKey;

FOUNDATION_EXPORT NSString *const DDURLServiceFilesArrayKey;
FOUNDATION_EXPORT NSString *const DDURLServiceFileDataKey;
FOUNDATION_EXPORT NSString *const DDURLServiceFileFormNameKey;
FOUNDATION_EXPORT NSString *const DDURLServiceFileFileNameKey;
FOUNDATION_EXPORT NSString *const DDURLServiceFileContentTypeKey;

@interface DDURLService : NSObject


/*! 根据相关参数发送请求
 *
 * parameters[DDURLServiceURLKey] : 请求的 url，该参数为 NSString 类型，且必须存在
 *
 * parameters[DDURLServiceGetParametersKey] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * parameters[DDURLServicePostParametersKey] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * result[DDServiceResultKey] : 请求返回的数据 NSData (失败的时候返回NSError)
 */
+ (void)sendRequest:(DDService *)service;

/*! 根据相关参数发送请求
 *
 * parameters[DDURLServiceURLKey] : 请求的 url，该参数为 NSString 类型，且必须存在
 *
 * parameters[DDURLServiceGetParametersKey] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * parameters[DDURLServicePostParametersKey] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * parameters[DDURLServiceFilesArrayKey] : 要提交的文件数组 NSArray 类型 [fileDict1,fileDcit2 ……]
 * fileDict : {"DDURLServiceFileDataKey" : 要提交的文件(NSData), "DDURLServiceFileFormNameKey" :表单名（NSString）, "DDURLServiceFileFileNameKey" : 文件名（NSString）, "DDURLServiceFileContentTypeKey" : 文件类型（NSString:image/jpeg,）}
 *
 * result[DDServiceResultKey] : 请求返回的数据 NSData (失败的时候返回NSError)
 */
+ (void)sendMultiPartFormRequest:(DDService *)service;

@end
