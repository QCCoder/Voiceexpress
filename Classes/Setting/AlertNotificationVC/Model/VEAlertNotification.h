//
//  VEAlertNotification.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEAlertNotification : NSObject

//返回值
@property (nonatomic,assign) NSInteger result;
//夜间免打扰
@property (nonatomic,assign) BOOL isNightNodisturb;
//自动推送预警
@property (nonatomic,assign) BOOL isPush;
//紧急
@property (nonatomic,assign) BOOL isGenralAlert;
//重要
@property (nonatomic,assign) BOOL isSeriousAlert;
//一般
@property (nonatomic,assign) BOOL isUrgentAlert;

@property (nonatomic,copy) NSString *iveLevels;

@property (nonatomic,copy) NSString *veLevels;



@end
