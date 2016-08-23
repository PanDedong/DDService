//
//  DDTestServiceVC.m
//  DDToolBox
//
//  Created by panda on 14-8-1.
//  Copyright (c) 2014年 panda. All rights reserved.
//

#import "DDTestServiceVC.h"
#import "DDTestService.h"

#define Location_BeiJing    @"39.990912172420714,116.32715863448607"
#define Location_ShangHai   @"31.244750205504,121.50713723717"
#define Location_GuangZhou  @"23.103198898609,113.30435199563"

@interface DDTestServiceVC ()

@property (strong, nonatomic) UILabel *resultLbl;

@end

@implementation DDTestServiceVC


- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送请求" style:UIBarButtonItemStylePlain target:self action:@selector(requestButtonPressed)];
    
    self.resultLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 60)];
    self.resultLbl.textAlignment = NSTextAlignmentCenter;
    self.resultLbl.numberOfLines = 0.0;
    self.resultLbl.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    self.resultLbl.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
    self.resultLbl.font = [UIFont systemFontOfSize:14];
    self.resultLbl.hidden = YES;
    [self.view addSubview:self.resultLbl];
    
    switch (self.viewtype)
    {
        case DDTestViewConcurrentType:
            self.navigationItem.title = @"ConcurrentType";
            break;
        case DDTestViewSerialType:
            self.navigationItem.title = @"SerialType";
            break;
        case DDTestViewNormalType:
            self.navigationItem.title = @"NormalType";
            break;
        default:
            break;
    }
}

- (void)requestButtonPressed
{
    switch (self.viewtype)
    {
        case DDTestViewConcurrentType:
            [self simulateConcurrent];
            break;
        case DDTestViewSerialType:
            [self simulateSerial];
            break;
        case DDTestViewNormalType:
            [self simulateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - simulateConcurrent

- (void)simulateConcurrent
{
    self.navigationItem.rightBarButtonItem.title = @"发送中...";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //测试两次请求的 自动取消上一次的
    [DDService startAsyncService:DDServiceTypeMake([DDTestService class], @selector(getCitiesWether:))
                      parameters:@{@"locations": @[Location_BeiJing, Location_GuangZhou, Location_ShangHai]}
                          target:self
                        selector:@selector(simulateConcurrentResponse:)];
    [DDService startAsyncService:DDServiceTypeMake([DDTestService class], @selector(getCitiesWether:))
                      parameters:@{@"locations": @[Location_BeiJing, Location_GuangZhou, Location_ShangHai]}
                          target:self
                        selector:@selector(simulateConcurrentResponse:)];
}

- (void)simulateConcurrentResponse:(DDService *)service {
    self.navigationItem.rightBarButtonItem.title = @"发送请求";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (service.status == DDServiceStatusFinished) {
        self.resultLbl.text = [service.result[DDServiceResultKey] componentsJoinedByString:@"\n"];
        self.resultLbl.hidden = NO;
    }
}

#pragma mark - simulateSerial

- (void)simulateSerial
{
    self.navigationItem.rightBarButtonItem.title = @"发送中...";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [DDService startAsyncService:DDServiceTypeMake([DDTestService class], @selector(getWetherWithLocation:))
                      parameters:@{@"location":Location_BeiJing}
                          target:self
                        selector:@selector(simulateSerialResponse:)];
    [DDService startAsyncService:DDServiceTypeMake([DDTestService class], @selector(getWetherWithLocation:))
                      parameters:@{@"location":Location_BeiJing}
                          target:self
                        selector:@selector(simulateSerialResponse:)];
}

- (void)simulateSerialResponse:(DDService *)service
{
    self.navigationItem.rightBarButtonItem.title = @"发送请求";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (service.status == DDServiceStatusFinished)
    {
        self.resultLbl.text = [NSString stringWithFormat:@"城市：%@ 天气:%@",service.result[@"city"],service.result[@"wether"]];
        self.resultLbl.hidden = NO;
    }
}

#pragma mark - simulateNormal

- (void)simulateNormal
{
    self.navigationItem.rightBarButtonItem.title = @"发送中...";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [DDService startAsyncService:DDServiceTypeMake([DDTestService class], @selector(reverseGeocodeLocation:))
                      parameters:@{@"location":Location_BeiJing}
                          target:self
                        selector:@selector(simulateNormalResponse:)];
}

- (void)simulateNormalResponse:(DDService *)service
{
    self.navigationItem.rightBarButtonItem.title = @"发送请求";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (service.status == DDServiceStatusFinished)
    {
        self.resultLbl.text = [NSString stringWithFormat:@"城市：%@",service.result[@"result"]];
        self.resultLbl.hidden = NO;
    }
}

@end
