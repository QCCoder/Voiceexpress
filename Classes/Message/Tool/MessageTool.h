//
//  MessageTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntelligenceColumnAgent.h"
#import "IntelligenceAgent.h"
#import "Intelligence.h"
#import "ReplyAgent.h"
#import "DistributeRequest.h"

#define kIntelligenceIsRead             @"VEIntelligenceIsRead"
#define kIntelligenceIsReadMarkUpload   @"VEIntelligenceIsReadMarkUpload"
#define kIntelligenceLatestTimeReply    @"VEIntelligenceLatestTimeReply"

typedef NS_ENUM(NSInteger, BoxType){
    // 数值不要修改
    BoxTypeInput = 1,           // 收件箱
    BoxTypeOutput = 2,          // 发件箱
    BoxTypeRelativeMe = 3,      // 与我相关
    BoxTypeAllIntelligence = 4,
};

@interface MessageTool : NSObject
/**
 *  是否有检查新情报交互
 */
+(void)checkNewAlert:(ResultInfoBlock)resultInfo;

/**
 *  情报交互二级列表页数据
 */
+(void)loadMessageListWithParamters:(NSDictionary *)paramters lastAid:(NSString *)lastAid boxType:(BoxType)boxType resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  删除情报交互信息
 */
+(void)deleteMessageWithAid:(NSString *)aid resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  标记已读
 */
+(void)markReadWithAid:(NSString *)aids resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  加载收信人
 */
+(void)loadReceiversWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  加载文章详情
 */
+(void)loadAriticleWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  加载回复
 */
+(void)loadReplyWithAid:(NSString *)aid boxType:(BoxType)boxType resultInfo:(ResultInfoBlock)resultInfo;

+(void)loadWarnTypeAgent:(SuccessBlock)seccess;

+(void)distributeAlert:(DistributeRequest *)request imageList:(NSArray *)imageList resultInfo:(ResultInfoBlock)resultInfo;
/**
 *  图片上传
 */
+(void)uploadImage:(NSArray *)imageList Success:(SuccessBlock)success Failure:(FailureBlock)failure;


+ (double)newestTimeAtIntelligenceColumnType:(IntelligenceColumnType)columnType;

+ (void)setNewestTime:(double)newTimeReply atIntelligenceColumnType:(IntelligenceColumnType)columnType;


+ (NSDictionary *)intelligenceInfoInBoxType:(BoxType)boxType withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;
+ (void)setIntelligenceInfo:(NSDictionary *)info InBoxType:(BoxType)boxType withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType;

@end
