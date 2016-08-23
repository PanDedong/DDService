//
//  DDTestService.h
//  DDService
//
//  Created by panda on 14-7-1.
//  Copyright (c) 2014年 dedong pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDService.h"
#import "DDService+Network.h"

@interface DDTestService : NSObject

+ (void)reverseGeocodeLocation:(DDService *)service;

+ (void)getWetherWithCity:(DDService *)service;

+ (void)getWetherWithLocation:(DDService *)service;

+ (void)getCitiesWether:(DDService *)service;

@end
