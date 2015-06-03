//
//  DDTestService.m
//  DDService
//
//  Created by panda on 14-7-1.
//  Copyright (c) 2014年 dedong pan. All rights reserved.
//

#import "DDTestService.h"
#import "DDService.h"
#import "DDURLService.h"

#define BDMap_Geo_Url @"http://api.map.baidu.com/geocoder"

@implementation DDTestService

+ (void)reverseGeocodeLocation:(DDService *)service
{
    NSString *location = service.parameters[@"location"];
    [service startChildService:_DDST([DDURLService class], @selector(sendRequest:))
                    parameters:@{DDURLSERVICE_URL: BDMap_Geo_Url,
                                 DDURLSERVICE_GET_PARAMETERS: @{
                                         @"location": location,
                                         @"coord_type": @"gcj02",
                                         @"output": @"json",
                                         },
                                 }
                    completion:^(DDService *childService)
     {
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:childService.result[DDURLSERVICE_RESULT] options:NSJSONReadingMutableContainers error:NULL];
         NSString *city = json[@"result"][@"addressComponent"][@"city"];
         city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
         service.result = @{@"result":city};
     }];
}

+ (void)getWetherWithCity:(DDService *)service
{
    NSDictionary *cityCodeDict = @{
        @"北京": @"101010100",
        @"广州": @"101280101",
        @"上海": @"101020100",
    };
    
    NSString *wetherUrl = [NSString stringWithFormat:@"http://www.weather.com.cn/adat/sk/%@.html", cityCodeDict[service.parameters[@"city"]]];
    [service startChildService:_DDST([DDURLService class], @selector(sendRequest:))
                    parameters:@{DDURLSERVICE_URL: wetherUrl,}
                    completion:^(DDService *childService)
     {
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:childService.result[DDURLSERVICE_RESULT] options:NSJSONReadingMutableContainers error:NULL];
         NSString *wether = json[@"weatherinfo"][@"WD"];
         service.result = @{@"result": wether};
     }];
}

+ (void)getWetherWithLocation:(DDService *)service
{
    [service startChildService:_DDST([DDTestService class], @selector(reverseGeocodeLocation:))
                    parameters:service.parameters
                    completion:^(DDService *childService)
     {
         NSString *city = childService.result[@"result"];
         [service startChildService:_DDST([DDTestService class], @selector(getWetherWithCity:))
                         parameters:@{@"city":city}
                         completion:^(DDService *childService)
          {
              NSString *wether = childService.result[@"result"];
              service.result = @{@"city": city, @"wether": wether};
          }];
     }];
}

+ (void)getCitiesWether:(DDService *)service
{
    NSMutableArray *cityWetherArray = [NSMutableArray arrayWithCapacity:0];
    NSLock *lock = [[NSLock alloc] init];
    
    for (NSString *location in service.parameters[@"locations"]) {
        [service startAsyncChildService:_DDST([DDTestService class], @selector(getWetherWithLocation:))
                             parameters:@{@"location": location}
                             completion:^(DDService *childService)
         {
             NSString *resultString = [NSString stringWithFormat:@"城市：%@ 天气:%@",childService.result[@"city"], childService.result[@"wether"]];
             [lock lock];
             [cityWetherArray addObject:resultString];
             [lock unlock];
         }];
    }
    
    [service completionedAllAsyncChildServicesNotify:^{
        service.status = DDServiceStatusFinished;
        service.result = @{DDSERVICE_RESULT: cityWetherArray};
    }];
}

@end
