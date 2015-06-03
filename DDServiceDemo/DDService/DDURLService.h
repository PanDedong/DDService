//
//  DDURLService.h
//
//  Created by Pan,Dedong on 13-10-9.
//  Version 1.0.0

//  This code is distributed under the terms and conditions of the MIT license.

//  Copyright (c) 2013-2014 Pan,Dedong
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

#define DDURLSERVICE_URL                @"DDURLSERVICE_URL"

#define DDURLSERVICE_POST_PARAMETERS    @"DDURLSERVICE_POST_PARAMETERS"
#define DDURLSERVICE_GET_PARAMETERS     @"DDURLSERVICE_GET_PARAMETERS"
#define DDURLSERVICE_RESULT             DDSERVICE_RESULT

#define DDURLSERVICE_FILE_ARRAY         @"DDURLSERVICE_FILEARRAY"
#define DDURLSERVICE_FILE_FILEDATA      @"DDURLSERVICE_FILE_FILEDATA"
#define DDURLSERVICE_FILE_KEYNAME       @"DDURLSERVICE_FILE_KEYNAME"
#define DDURLSERVICE_FILE_FILENAME      @"DDURLSERVICE_FILE_FILENAME"
#define DDURLSERVICE_FILE_CONTENTTYPE   @"DDURLSERVICE_FILE_CONTENTTYPE"

@interface DDURLService : NSObject


/*! 根据相关参数发送请求
 *
 * service.parameters[DDURLSERVICE_URL] : 请求的 url，该参数为 NSString 类型，且必须存在
 *
 * service.parameters[DDURLSERVICE_GET_PARAMETERS] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * service.parameters[DDURLSERVICE_POST_PARAMETERS] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * service.result[DDURLSERVICE_RETURN] : 请求返回的数据 NSData (失败的时候返回NSError)
 */
+ (void)sendRequest:(DDService *)service;

/*! 根据相关参数发送请求
 *
 * service.parameters[DDURLSERVICE_URL] : 请求的 url，该参数为 NSString 类型，且必须存在
 *
 * service.parameters[DDURLSERVICE_GET_PARAMETERS] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * service.parameters[DDURLSERVICE_POST_PARAMETERS] : 请求的参数 NSDictionary 类型:{ "key" : "value", "key" : "value" ……}， 可不传
 *
 * service.parameters[DDURLSERVICE_FILESARRAY] : 要提交的文件数组 NSArray 类型 [fileDict1,fileDcit2 ……]
 * fileDict : {"DDURLSERVICE_FILE_FILEDATA" : 要提交的文件(NSData), "DDURLSERVICE_FILE_KEYNAME" :表单名（NSString）, "DDURLSERVICE_FILE_FILENAME" : 文件名（NSString）, "DDURLSERVICE_FILE_CONTENTTYPE" : 文件类型（NSString:image/jpeg,）}
 *
 * service.result[DDURLSERVICE_RETURN] : 请求返回的数据 NSData (失败的时候返回NSError)
 */
+ (void)sendMultiPartFormRequest:(DDService *)service;

@end
