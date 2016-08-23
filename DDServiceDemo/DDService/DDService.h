//
//  DDService.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDServiceStatus) {
    DDServiceStatusFinished,
    DDServiceStatusFailed,
};

FOUNDATION_EXPORT NSString *const DDServiceResultKey;

FOUNDATION_EXPORT NSString *DDServiceTypeMake(Class aClass, SEL aSelector);

@interface DDService : NSObject

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) NSDictionary *result;
@property (assign, nonatomic) DDServiceStatus status;
@property (strong, nonatomic) NSString *statusMsg;

+ (void)addResponder:(id)responder selector:(SEL)selector forService:(NSString *)type;

+ (void)cancelService:(NSString *)type target:(id)target;

+ (DDService *)startSyncService:(NSString *)type
                     parameters:(NSDictionary *)parameters;

+ (void)startSyncService:(NSString *)type
              parameters:(NSDictionary *)parameters
              completion:(void (^)(DDService *service))completion;

+ (void)startAsyncService:(NSString *)type
               parameters:(NSDictionary *)parameters
                   target:(id)target
                 selector:(SEL)selector;

+ (void)startAsyncService:(NSString *)type
               parameters:(NSDictionary *)parameters
               completion:(void (^)(DDService *service))completion;

- (DDService *)startChildService:(NSString *)type
                      parameters:(NSDictionary *)parameters;

- (void)startChildService:(NSString *)type
               parameters:(NSDictionary *)parameters
               completion:(void (^)(DDService *childService))completion;

- (void)startAsyncChildService:(NSString *)type
                    parameters:(NSDictionary *)parameters
                    completion:(void (^)(DDService *childService))completion;

- (void)completionedAllAsyncChildServicesNotify:(void (^)(void))block;

- (void)failedWithMsg:(NSString *)msg;

@end

