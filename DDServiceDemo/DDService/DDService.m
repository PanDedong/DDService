//
//  DDService.m
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

#import "DDService.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define _DDClass(serviceType) [DDService classFromServiceType:(serviceType)]
#define _DDSEL(serviceType) [DDService selectorFromServiceType:(serviceType)]
#define DDSERVICE_EXCEPTION_NAME_FAIL   @"DDService_exception_name_fail"
#define DDSERVICE_EXCEPTION_NAME_CANCEL @"DDService_exception_name_cancel"

@interface NSException (DDService)

- (BOOL)isDDServiceException;

@end

@implementation NSException (DDService)

- (BOOL)isDDServiceException {
    BOOL isDDserviceException = NO;
    if ([self.name isEqualToString:DDSERVICE_EXCEPTION_NAME_FAIL] ||
        [self.name isEqualToString:DDSERVICE_EXCEPTION_NAME_CANCEL])
    {
        isDDserviceException = YES;
    }
    return isDDserviceException;
}

@end

@interface DDService ()

@property (assign, nonatomic) BOOL wantCancel;
@property (weak, nonatomic) DDService *parentService;
@property (strong, nonatomic) dispatch_group_t childServicesGroup;
@property (strong, nonatomic) NSException *childException;

+ (Class)classFromServiceType:(NSString *)type;
+ (SEL)selectorFromServiceType:(NSString *)type;

@end

@interface DDServiceRunner : NSObject

@property (strong, nonatomic) DDService *service;

@end

@interface DDServiceCompletion : NSObject

@property (strong, nonatomic) NSString *serviceType;
@property (weak, nonatomic) id target;
@property (strong, nonatomic) NSString *selectorString;
@property (strong, nonatomic) void (^completionBlock)(DDService *service);

@end

@interface DDServiceResponder : NSObject

@property (strong, nonatomic) DDServiceCompletion *completion;

@end

@interface DDServiceCenter : NSObject {
    NSMutableArray      *_completionsArray;
    dispatch_queue_t    _mySerialQueue;
}

+ (DDServiceCenter *)defaultCenter;
- (void)addResponder:(id)responder selector:(SEL)selector forService:(NSString *)type;
- (void)removeComplection:(DDServiceCompletion *)complection;
- (void)responseForService:(DDService *)service;

@end

@implementation DDServiceCenter

- (instancetype)init {
    if (self = [super init]) {
        _completionsArray = [[NSMutableArray alloc] init];
        _mySerialQueue = dispatch_queue_create("DDService.center.serialqueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (DDServiceCenter *)defaultCenter {
    static dispatch_once_t onceToken;
    static DDServiceCenter *center = nil;
    dispatch_once(&onceToken, ^{
        center = [[DDServiceCenter alloc] init];
    });
    return center;
}

- (void)addResponder:(id)responder selector:(SEL)selector forService:(NSString *)type {
    if (![responder respondsToSelector:selector]) return;
    
    dispatch_async(_mySerialQueue, ^{
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"serviceType == %@ AND target == %@ AND selectorString == %@",type,responder,NSStringFromSelector(selector)];
        NSArray *array = [_completionsArray filteredArrayUsingPredicate:filterPredicate];
        if (array.count > 0) return;
        
        DDServiceCompletion *completion = [[DDServiceCompletion alloc] init];
        completion.serviceType = type;
        completion.target = responder;
        completion.selectorString = NSStringFromSelector(selector);
        id __weak weakResponder = responder;
        completion.completionBlock =  ^(DDService *service)
        {
            id __strong strongResponder = weakResponder;
            if (strongResponder) {
                ((void (*)(id, SEL, id))objc_msgSend)(strongResponder, selector, service);
            }
        };
        [_completionsArray addObject:completion];
        
        DDServiceResponder *serviceResponder = [[DDServiceResponder alloc] init];
        serviceResponder.completion = completion;
        
        objc_setAssociatedObject(responder, (__bridge const void *)(type), serviceResponder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

- (void)removeComplection:(DDServiceCompletion *)complection {
    dispatch_async(_mySerialQueue, ^{
        [_completionsArray removeObject:complection];
    });
}

- (void)responseForService:(DDService *)service {
    dispatch_async(_mySerialQueue, ^{
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K == %@",@"serviceType",service.type];
        NSArray *completionArray = [_completionsArray filteredArrayUsingPredicate:filter];
        if (completionArray.count > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (DDServiceCompletion *serviceCompletion in completionArray)
                {
                    serviceCompletion.completionBlock(service);
                }
            });
        }
    });
}

- (BOOL)existComplectionForServiceWithType:(NSString *)type target:(id)target selector:(SEL)selector {
    NSArray *completionArray = [_completionsArray copy];
    NSPredicate *filterPredicate = nil;
    if (target && selector) {
        filterPredicate = [NSPredicate predicateWithFormat:@"serviceType == %@ AND target == %@ AND selectorString == %@",type,target,NSStringFromSelector(selector)];
    }
    else {
        filterPredicate = [NSPredicate predicateWithFormat:@"serviceType == %@",type];
    }
    
    NSArray *array = [completionArray filteredArrayUsingPredicate:filterPredicate];
    
    return array.count > 0 ? YES : NO;
}

- (BOOL)existComplectionForServiceWithType:(NSString *)type {
    return [self existComplectionForServiceWithType:type target:nil selector:nil];
}

@end

@implementation DDServiceRunner

- (void)dealloc {
    if (![[DDServiceCenter defaultCenter] existComplectionForServiceWithType:self.service.type]) {
        self.service.wantCancel = YES;
    }
}

@end

@implementation DDServiceCompletion

@end

@implementation DDServiceResponder

- (void)dealloc {
    [[DDServiceCenter defaultCenter] removeComplection:self.completion];
}

@end

@implementation DDService

- (instancetype)init {
    if (self = [super init]) {
        _wantCancel = NO;
    }
    return self;
}

+ (Class)classFromServiceType:(NSString *)type {
    NSString *classString = [type componentsSeparatedByString:@"."].firstObject;
    return NSClassFromString(classString);
}

+ (SEL)selectorFromServiceType:(NSString *)type {
    NSString *selectorString = [type componentsSeparatedByString:@"."].lastObject;
    return NSSelectorFromString(selectorString);
}

+ (NSString *)typeForClass:(Class)aClass selector:(SEL)selector {
    NSAssert([aClass respondsToSelector:selector], @"%@ did not responds to%@", NSStringFromClass(aClass), NSStringFromSelector(selector));
    return [NSStringFromClass(aClass) stringByAppendingFormat:@".%@",NSStringFromSelector(selector)];
}

#pragma mark - DDService Public method

+ (void)addResponder:(id)responder selector:(SEL)selector forService:(NSString *)type {
    [[DDServiceCenter defaultCenter] addResponder:responder selector:selector forService:type];
}

+ (void)cancelService:(NSString *)type target:(id)target {
    if (target) {
        objc_setAssociatedObject(target, class_getClassMethod(_DDClass(type), _DDSEL(type)), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (DDService *)startSyncService:(NSString *)type
                     parameters:(NSDictionary *)parameters
{
    DDService *service = [[DDService alloc] init];
    service.type = type;
    service.parameters = parameters;
    
    [DDService tryStartService:service];
    
    [[DDServiceCenter defaultCenter] responseForService:service];
    
    return service;
}

+ (void)startSyncService:(NSString *)type
              parameters:(NSDictionary *)parameters
              completion:(void (^)(DDService *service))completion
{
    DDService *service = [DDService startSyncService:type parameters:parameters];
    if (completion) completion(service);
}

+ (void)startAsyncService:(NSString *)type
               parameters:(NSDictionary *)parameters
                   target:(id)target
                 selector:(SEL)selector
{
    if (!target && !selector && ![[DDServiceCenter defaultCenter] existComplectionForServiceWithType:type]) {
#ifdef DEBUG
        NSLog(@"\n***************\nNot start!! there is no responder exist.\n*******************");
#endif
        return;
    }
    
    if (target && ![target respondsToSelector:selector]) {
#ifdef DEBUG
        NSLog(@"\n***************\nNot start!! %@ did not respond to%@\n*******************", NSStringFromClass(target), NSStringFromSelector(selector));
#endif
        return;
    }
    
    DDService *service = [[DDService alloc] init];
    service.type = type;
    service.parameters = parameters;
    
    if (target) {
        DDServiceRunner *runner = [[DDServiceRunner alloc] init];
        runner.service = service;
        objc_setAssociatedObject(target, class_getClassMethod(_DDClass(type), _DDSEL(type)), runner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    id __weak weakTarget = target;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [DDService tryStartService:service];
        if (service.wantCancel == YES) return;

        id __strong strongTarget = weakTarget;
        if (strongTarget) {
            objc_setAssociatedObject(strongTarget, class_getClassMethod(_DDClass(type), _DDSEL(type)), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if (![[DDServiceCenter defaultCenter] existComplectionForServiceWithType:type target:strongTarget selector:selector]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ((void (*)(id, SEL, id))objc_msgSend)(strongTarget, selector, service);
                });
            }
        }
        
        [[DDServiceCenter defaultCenter] responseForService:service];
    });
}

+ (void)startAsyncService:(NSString *)type
               parameters:(NSDictionary *)parameters
               completion:(void (^)(DDService *service))completion
{
    if (!completion && ![[DDServiceCenter defaultCenter] existComplectionForServiceWithType:type]) {
#ifdef DEBUG
        NSLog(@"\n***************\nNot start!! there is no responder exist.\n*******************");
#endif
        return;
    }
    
    DDService *service = [[DDService alloc] init];
    service.type = type;
    service.parameters = parameters;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [DDService tryStartService:service];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(service);
            });
        }
        [[DDServiceCenter defaultCenter] responseForService:service];
    });
}

- (DDService *)startChildService:(NSString *)type parameters:(NSDictionary *)parameters {
    DDService *service = [[DDService alloc] init];
    service.type = type;
    service.parameters = parameters;
    service.parentService = self;
    
    [DDService tryStartService:service];
    
    return service;
}

- (void)startChildService:(NSString *)type
               parameters:(NSDictionary *)parameters
               completion:(void (^)(DDService *childService))completion
{
    DDService *service = [self startChildService:type parameters:parameters];
    if (completion) completion(service);
}

- (void)startAsyncChildService:(NSString *)type
                    parameters:(NSDictionary *)parameters
                    completion:(void (^)(DDService *childService))completion
{
    if (!self.childServicesGroup) self.childServicesGroup = dispatch_group_create();
    
    DDService *service = [[DDService alloc] init];
    service.type = type;
    service.parameters = parameters;
    service.parentService = self;
    
    dispatch_group_async(self.childServicesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [DDService tryStartService:service];
        if (completion) completion(service);
    });
}

- (void)completionedAllAsyncChildServicesNotify:(void (^)(void))block {
    if (!self.childServicesGroup) return;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_notify(self.childServicesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (block) block();
    self.childServicesGroup = nil;
    if (self.childException) @throw self.childException;
}

- (void)failedWithMsg:(NSString *)msg {
    DDService *rootService = [self rootService];
    rootService.statusMsg = msg;
    rootService.status = DDServiceStatusFailed;
    rootService.result = self.result;
    NSException *exception = [[NSException alloc] initWithName:DDSERVICE_EXCEPTION_NAME_FAIL reason:msg userInfo:nil];
    @throw exception;
}

#pragma mark - DDService Private method

- (DDService *)rootService {
    DDService *rootService = self;
    while (rootService.parentService) {
        rootService = rootService.parentService;
    }
    return rootService;
}

+ (void)tryStartService:(DDService *)service {
    @autoreleasepool {
        @try {
            if ([service rootService].wantCancel) {
                NSException *exception = [[NSException alloc] initWithName:DDSERVICE_EXCEPTION_NAME_CANCEL reason:nil userInfo:nil];
                @throw exception;
            }
            
            ((void (*)(id, SEL, id))objc_msgSend)(_DDClass(service.type), _DDSEL(service.type), service);
            if (service.childServicesGroup) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                dispatch_group_notify(service.childServicesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_semaphore_signal(semaphore);
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                service.childServicesGroup = nil;
                if (service.childException) @throw service.childException;
            }
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            if (![exception isDDServiceException]) {
                NSLog(@"\n***************\nCaught exception when %@\n%@\n*******************",service.type, exception);

            }
#endif
            
            if (service.parentService){
                if (service.parentService.childServicesGroup) {
                    service.parentService.childException = exception;
                }
                else if (![exception isDDServiceException]){
                    NSException *failException = [[NSException alloc] initWithName:DDSERVICE_EXCEPTION_NAME_FAIL reason:nil userInfo:nil];
                    @throw failException;
                }
                else {
                    @throw exception;
                }
            }
            else {
                service.status = DDServiceStatusFailed;
            }
        }
    }
}

@end
