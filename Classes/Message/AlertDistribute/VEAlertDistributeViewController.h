//
//  VEAlertDistributeViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-12-23.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTool.h"

extern BOOL VEAlertDistributeViewSuccessDistribute;

typedef NS_ENUM(NSInteger, ForwardFrom)
{
    ForwardFromIntelligenceAlert = 0,  // 情报交互
    ForwardFromWarnAlert,              // 最新预警，推荐阅读，舆情搜索
    ForwardFromInternet,               // 区县上报
};



@interface VEAlertDistributeViewController : BaseViewController


@property (nonatomic, assign) IntelligenceColumnType    columnType;
//@property (nonatomic, assign) SendType                  sendType;


// for forward
@property (nonatomic, strong) NSArray                   *forwardImageUrls;
@property (nonatomic, copy) NSString                    *forwardArticleContent;
@property (nonatomic, strong) Agent                     *forwardAgent;
@property (nonatomic, copy) NSString                     *suggest;
@property (nonatomic, assign) NSInteger                  suggestId;
@property (nonatomic, copy) NSString                     *showTitle;
@property (nonatomic, assign) ForwardFrom               forwardFromType;
@property (nonatomic, strong ) WarnningTypeAgent         *warnningTypeAgent;


-(instancetype)initWithWarnningTypeAgent:(WarnningTypeAgent *)agent;

@property (nonatomic,copy) void(^sendSuccess)();
@end
