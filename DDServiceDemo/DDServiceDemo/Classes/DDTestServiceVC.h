//
//  DDTestServiceVC.h
//  DDToolBox
//
//  Created by panda on 14-8-1.
//  Copyright (c) 2014年 panda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DDTestViewType) {
    DDTestViewConcurrentType,
    DDTestViewSerialType,
    DDTestViewNormalType,
};

@interface DDTestServiceVC : UIViewController

@property (assign, nonatomic) DDTestViewType viewtype;

@end
