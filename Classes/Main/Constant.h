//
//  Constant.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-8-21.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "FrameAccessor.h"
#import "VEJsonParser.h"
#import "DES3Util.h"
#import "Agent.h"
#import "VEUtility.h"
#import "UIBarButtonItem+Extension.h"


#ifndef voiceexpress_Constant_h
#define voiceexpress_Constant_h


//static NSString * const kBaseURL = @"http://192.168.0.246:8090/gaphone/mobile";

//二期测试
static NSString * const kBaseURL = @"http://192.168.188.161:8080/gaphone/mobile";

//static NSString * const kBaseURL = @"http://192.168.188.137:8080/gaphone/mobile";

//static NSString * const kBaseURL = @"http://192.168.0.13:8085/gaphone/mobile";

//static NSString * const kBaseURL = @"http://122.227.230.84:9016/gaphone/mobile";

//二期服务端
//static NSString * const kBaseURL = @"http://122.227.230.81:8090/gaphone/mobile";


///////////////////////////////////////////////////////////////////////////////
//详情页行距
#define LINESPACE 8
#define HTTPERROR 10000
static NSString * const kBranch        = @"ga";
static const NSInteger  kBatchSize     = 20;
static const NSUInteger kMaxImageSize  = 500 * 1024;  // 500KB

static NSString * const kToolBarBackgroundImage = @"toolBar-BKImage";
static NSString * const kRecommendReadNewFlag   = @"ico-new";
static NSString * const kDefaultLogPic          = @"ico-log-default";

static NSString * const kWhiteBK                = @"bar-listbg-new";
static NSString * const kGrayBK                 = @"bar-listbg-old";

static NSString * const kContactApproach        = @"contact@cyyun.com";
static NSString * const kSupportApproach        = @"fanyn@cyyun.com";

// Cell
static const NSInteger kCellTitleTag        = 10;
static const NSInteger kCellSiteTag         = 11;
static const NSInteger kCellCountsTag       = 11;
static const NSInteger kCellInfoTag         = 11;
static const NSInteger kCellTimePostTag     = 12;

static const NSInteger kCellImgLevelTag     = 13;
static const NSInteger kCellAuthorTag       = 13;
static const NSInteger kCellImgNewTag       = 13;
static const NSInteger kCellImgBKTag        = 14;
static const NSInteger kCellImgLogTag       = 15;
static const NSInteger kCellLocalAreaTag    = 15;
static const NSInteger kCellDeleteBtnTag    = 16;

static const NSInteger kCellAreaTagOne      = 101;
static const NSInteger kCellAreaTagTwo      = 102;
static const NSInteger kCellAreaTagThree    = 103;

// Font size
static const NSInteger kMinFontSize     = 12;
static const NSInteger kMaxFontSize     = 36;

// Notification
static NSString * const kNewFlagChangedNotification             = @"VENewFlagChangedNotification";
static NSString * const kNewDayHappenedNotification             = @"VENewDayHappenedNotification";
static NSString * const kAppDidReceiveRemoteNotification        = @"VEAppDidReceiveRemoteNotification";
static NSString * const kAppChangeLeftPanSelIndexNotification   = @"VEAppChangeLeftPanSelIndexNotification";


// UM Appkey
static NSString * const kUMAnalyticsAppKey = @"5403d7d4fd98c5be9800047f";

// content font size
static const NSInteger kSmallFontSize       = 14;
static const NSInteger kMiddleFontSize      = 18;
static const NSInteger kBigFontSize         = 22;
static const NSInteger kSuperBigFontSize    = 28;

#endif









