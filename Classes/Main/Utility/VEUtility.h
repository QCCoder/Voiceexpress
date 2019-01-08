//
//  VEUtility.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-13.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "VEWarnAlertTableViewCell.h"
#import "Agent.h"
#import "RecommendAgent.h"
#import "Reachability.h"

static NSString * const kHasNewVersion                  = @"VEHasNewVersion";
static NSString * const kMandatoryUpdate                = @"VEMandatoryUpdate";
static NSString * const kUpdateDiscription              = @"VEUpdateDiscription";


@interface VEUtility : NSObject



+ (VEUtility *)sharedInstance;

+ (NSInteger)selectedIndex;

// 获取当前程序的版本号
+ (NSString *)curAppVersion;

// 判别是否连接网络
+ (BOOL)isNetworkReachable;

// 判别是否需要自动登陆
+ (BOOL)shouldAutoLoginToServer;

+ (void)setShouldAutoLoginToServer:(BOOL)value;

// 判别在2G/3G网络下是否自动接收图片
+ (BOOL)shouldReceivePictureOnCellNetwork;

+ (void)setShouldReceivePictureOnCellNetwork:(BOOL)value;

// 判别当前网络是否为Wifi
+ (BOOL)isCurrentNetworkWifi;

// url编码
+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

// 检测版本更新
+ (NSDictionary *)checkNewVersion;

// 下载最新版本
+ (void)downLoadNewVersion;

// 注册Apns推送
+ (void)registerForRemoteNotifications;

// 注销Apns推送
+ (void)unregisterForRemoteNotifications;

// 重导日志文件
+ (void)redirectNSLogToLogsFolder;

// 切换至登录界面
+ (void)returnToLoginInterface:(BOOL)bShowAlert;

// 初始化ToolBar的背景颜色
+ (void)initBackgroudImageOfToolBar:(UIToolbar *)toolBar;

// 显示指定的错误信息
+ (void)showServerErrorMeassage:(NSString *)errorMessage;

// 将时间类型数据转换为字符串
+ (NSString *)timeIntervalToString:(NSTimeInterval)timeInterval;

// 压缩图像
+ (NSData *)compressImage:(UIImage *)orginalImage withMaxSize:(NSUInteger)maxSize;

// MD5加密
+ (NSString *)md5:(NSString *)stringToEncode;

// 清理过期的历史缓存数据
+ (void)clearOverdueDataAtPersistentStore;

// 锁屏
+ (void)lockScreen:(RESideMenu *)deckVC;

// 清理设备锁信息
+ (void)clearUpDeviceLock;

// 设备锁错误次数
+ (void)setLockErrorTimes:(NSInteger)errorTimes;

+ (NSInteger)lockErrorTimes;

// 设备锁密码
+ (NSString *)currentPatternLockPassword;

+ (void)setPatternLockPassword:(NSString *)lockPassword;

// 设备锁锁定时间
+ (NSInteger)currentPatternLockTime;

+ (void)setPatternLockTime:(NSInteger)lockTime;

+ (NSString *)isFirstLogin;
+ (void)setIsFirstLogin:(NSString *)isFirstLogin;


// 设备锁是否激活
+ (BOOL)isDeviceLockActivated;

+ (void)setPatternLockActivated:(BOOL)isActivated;

+ (void)clearBadgeValueInServer;

+ (void)Logout;

+ (BOOL)isFailedToClearBadge;

+ (void)setFailedToClearBadge:(BOOL)bFailed;

+ (void)changeCustomGroupIds:(NSString *)groupIds withSort:(NSString *)sort;

// Creates a UUID to use as the temporary file name during the download
+ (NSString *)createUUID;

// 当前用户名
+ (NSString *)currentUserName;

+ (void)setCurrentUserName:(NSString *)userName;

// 当前皮肤版本号
+ (NSString *)currentSkinVersion;

+ (void)setCurrentSkinVersion:(NSString *)version;

+ (NSString *)currentLocalVersion;
+ (void)setCurrentLocalVersion:(NSString *)version;

// 当前用户密码
+ (NSString *)currentUserPassword;

+ (void)setCurrentUserPassword:(NSString *)userPassword;

// 当前用户ID
+ (NSString *)currentUserId;

+ (void)setCurrentUserId:(NSString *)userId;

// 服务器时间差
+ (NSString *)currentServiceTime;

+ (void)setCurrentServiceTime:(NSString *)time;

//手机令牌Token
+ (NSString *)currentMobileToken;

+ (void)setCurrentMobileToken:(NSString *)token;

//是否开启令牌
+ (NSString *)currentIsopenToken;

+ (void)setCurrentIsopenToken:(NSString *)token;


// 当前推送token
+ (NSString *)currentAPNSToken;

+ (void)setCurrentAPNSToken:(NSString *)token;

+ (BOOL)shouldShowSortableTipView;

+ (void)setShowSortableTipView:(BOOL)bShowAlert;

+ (NSInteger)contentFontSize;

+ (void)setContentFontSize:(NSInteger)fontSize;

//+ (double)newestTimeAtIntelligenceColumnType:(IntelligenceColumnType)columnType;
//
//+ (void)setNewestTime:(double)newTimeReply atIntelligenceColumnType:(IntelligenceColumnType)columnType;

+ (BOOL)isOnRed;

+ (void)setToggleButton:(UIButton *)toggleBtn onRed:(BOOL)isRed;

+ (void)postNewFlagChangedNotification;

+ (void)postNewDayHappenedNotification;

+ (NSString *)formatDateWithTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)getUMSUDID;


///////////////////////////////////////////////////

//+ (NSDictionary *)intelligenceInfoInBoxType:(BoxType)boxType withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;
//+ (void)setIntelligenceInfo:(NSDictionary *)info InBoxType:(BoxType)boxType withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;

+ (BOOL)isWarnReadWithArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType;
+ (void)setWarnReadWithArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType;

+ (NSString *)retrieveWarnContentWithArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;
+ (void)setWarnArticleContent:(NSString *)content withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;

////////////////////////////////////////////////////

//+ (UITableViewCell *)tableView:(UITableView *)tableView
//     cellForRecommendReadAgent:(RecommendAgent *)recommendAgent
//    cellSelectedBackgroundView:(UIView *)seledBackground;

+ (UITableViewCell *)cellForShowMoreTableView:(UITableView *)tableView
                   cellSelectedBackgroundView:(UIView *)seledBackground;

+ (UITableViewCell *)cellForShowNoResultTableView:(UITableView *)tableView
                                      fillMainTip:(NSString *)mainTip
                                    fillDetailTip:(NSString *)detailTip
                                  backgroundColor:(UIColor *)backgroundColor;
+ (UIView *)cellSelectedBackgroundView;

@end
