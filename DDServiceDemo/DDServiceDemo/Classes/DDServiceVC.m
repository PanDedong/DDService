//
//  DDServiceVC.m
//  DDToolBox
//
//  Created by panda on 14-8-1.
//  Copyright (c) 2014年 panda. All rights reserved.
//

#import "DDServiceVC.h"
#import "DDTestServiceVC.h"

@implementation DDServiceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.view.superview.backgroundColor = [UIColor whiteColor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (IBAction)concurrentButtonPressed:(UIButton *)button
{
    DDTestServiceVC *vc = [[DDTestServiceVC alloc] init];
    vc.viewtype = DDTestViewConcurrentType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)serialButtonPressed:(UIButton *)button
{
    DDTestServiceVC *vc = [[DDTestServiceVC alloc] init];
    vc.viewtype = DDTestViewSerialType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)normalButtonPressed:(UIButton *)button
{
    DDTestServiceVC *vc = [[DDTestServiceVC alloc] init];
    vc.viewtype = DDTestViewNormalType;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
