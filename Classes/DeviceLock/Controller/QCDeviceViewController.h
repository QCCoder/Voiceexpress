//
//  QCDeviceViewController.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    VEPatternLockActionInit,      // 初始化设备锁
    VEPatternLockActionLaunchInit,    // 启动程序后的初始化设备锁
    VEPatternLockActionVerify,        // 验证设备锁
    VEPatternLockActionClose,         // 关闭设备锁
}VEPatternLockAction;

@interface QCDeviceViewController : BaseViewController

@property (nonatomic, assign) VEPatternLockAction action;

@end
