//
//  DeviceItem.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceItem : UIView

typedef NS_ENUM(NSUInteger, QCDeviceTopStatus) {
    QCDeviceTopStatusNormal,
    QCDeviceTopStatusSelected,
    QCDeviceTopStatusWarning
};

@property (nonatomic,assign) QCDeviceTopStatus status;

@end
