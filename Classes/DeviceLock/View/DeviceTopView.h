//
//  DeviceTopView.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCDeviceViewController.h"
#import "DeviceItem.h"
@interface DeviceTopView : UIView

@property (nonatomic,copy) NSString *password;

@property (nonatomic,copy) NSString *title;

@property (nonatomic, assign) VEPatternLockAction action;

@property (nonatomic,assign) NSInteger selectedIndex;

-(void)cleanNode;

@property (nonatomic,assign) QCDeviceTopStatus status;
@end
