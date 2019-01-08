//
//  VEMessageDistributeViewController.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/16.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTool.h"

typedef NS_ENUM(NSInteger, SendType)
{
    SendTypeNewIntelligence = 1,                // 情报交互
    SendTypeForwardFromRecommendRead = 2,       // 推荐阅读转发情报交互
    SendTypeForwardFromWarnAlert = 3,           // 预警转发情报交互
    SendTypeForwardFromInternet = 4,            // 区县上报转发情报交互
    SendTypeForwardFromIntelligence = 5,        // 情报交互转发情报交互
};

@interface VEMessageDistributeViewController : BaseViewController

@property (nonatomic,assign) IntelligenceColumnType columnType;
@property (nonatomic, assign) SendType         sendType;
@property (nonatomic,copy) void(^sendSuccess)();

//转发情报交互
@property (nonatomic,strong) IntelligenceAgent *agent;
@property (nonatomic, strong) NSArray *imageUrls;

@end
