//
//  MessageTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MessageTool.h"
#import "ZLPhoto.h"
#import "MessageDetailResponse.h"
#import "UIImage+FixOrientation.h"
static const NSInteger k3MImageDataSize = 3 * 1024 * 1024;

@implementation MessageTool

/**
 *  情报交互一级列表页
 */
+(void)checkNewAlert:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomWarnListDistributedForGA" param:nil success:^(id JSON) {
        resultInfo(YES,JSON[@"list"]);
    } failure:^(NSError *error) {
        resultInfo(false,error);
    }];
}

/**
 *  情报交互列表页数据加载
 */
+(void)loadMessageListWithParamters:(NSDictionary *)paramters lastAid:(NSString *)lastAid boxType:(BoxType)boxType resultInfo:(ResultInfoBlock)resultInfo {
    
    [HttpTool postWithSessionClient:@"CustomWarnListForGA" param:paramters success:^(id JSON) {
        //bolck处理数据
        NSMutableArray *array = [NSMutableArray array];
        NSInteger countOfNew = 0;
        NSInteger newCount = 0;
        NSInteger count = 0;
        for (NSDictionary *dict in JSON[@"list"]) {
            IntelligenceAgent *intelligAgent =[[IntelligenceAgent alloc]initWithDictionary:dict];
            if (lastAid == intelligAgent.articleId) {
                count = newCount;
            }else{
                newCount++;
            }
            
            NSDictionary *intelligInfo = [self intelligenceInfoInBoxType:boxType
                                                           withArticleID:intelligAgent.articleId
                                                             andWarnType:intelligAgent.warnType];
            intelligAgent.isRead           = [[intelligInfo valueForKey:kIntelligenceIsRead] boolValue];
            intelligAgent.isReadMarkUpload = [[intelligInfo valueForKey:kIntelligenceIsReadMarkUpload] boolValue];
            double localLatestTimeReply    = [[intelligInfo valueForKey:kIntelligenceLatestTimeReply] doubleValue];
            intelligAgent.localTimeReply = localLatestTimeReply;
            if (boxType == BoxTypeOutput){//已发
                intelligAgent.isRead = YES;
            }
            
            if (intelligAgent.newestTimeReply > intelligAgent.localTimeReply){
                intelligAgent.isRead = NO;
            }
            
            if (!intelligAgent.isRead) {
                if (boxType == BoxTypeOutput) {
                    if (intelligAgent.newsTimeReply != 0) {
                        ++countOfNew;
                    }
                }else{
                    ++countOfNew;
                }
            }
            
//            intelligAgent.receivers = [NSMutableArray arrayWithArray:[self getReceivers:intelligAgent.receiverNames readArray:nil]];
            
            [array addObject:intelligAgent];
        }
        
        NSDictionary *dict = @{
                               @"list":array,
                               @"count":[NSString stringWithFormat:@"%ld",countOfNew],
                               @"newCount":[NSString stringWithFormat:@"%ld",count]
                               };
        resultInfo(true,dict);
    } failure:^(NSError *error) {
        DLog(@"%@",[error localizedDescription]);
        resultInfo(false,error);
    }];
}

/**
 *  删除情报交互
 */
+(void)deleteMessageWithAid:(NSString *)aid resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomWarnDelete" param:@{@"cwid":aid} success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)markReadWithAid:(NSString *)aids resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"markAllExchangeForGA" param:@{@"ids":aids} success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)loadAriticleWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"articledetail" param:paramters success:^(id JSON) {
        MessageDetailResponse *model = [MessageDetailResponse objectWithKeyValues:JSON];
        resultInfo(YES,model);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];

}

+(void)loadReplyWithAid:(NSString *)aid boxType:(BoxType)boxType resultInfo:(ResultInfoBlock)resultInfo{
    NSDictionary *dict = @{@"cwid":aid};
    
    if (boxType == BoxTypeAllIntelligence){
        dict = @{
                 @"cwid":aid,
                 @"allReply":@"true"};
    }
    [HttpTool postWithSessionClient:@"FindCustomWarnReplyForGA" param:dict success:^(id JSON) {
        ReplyGroup *group = [[ReplyGroup alloc]init];
        group.aboutMe = [ReplyGroupAgent objectArrayWithKeyValuesArray:JSON[@"aboutMe"]];
        group.toMe = [ReplyGroupAgent objectArrayWithKeyValuesArray:JSON[@"toMe"]];
        resultInfo(YES,group);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)loadWarnTypeAgent:(SuccessBlock)seccess{
    [HttpTool postWithSessionClient:@"CustomWarnLevelsForGA" param:nil success:^(id JSON) {
        seccess([WarnningTypeAgent objectArrayWithKeyValuesArray:JSON[@"list"]]);
    } failure:^(NSError *error) {
        DLog(@"%@",[error localizedDescription]);
    }];
}

+(void)distributeAlert:(DistributeRequest *)paramters imageList:(NSArray *)imageList resultInfo:(ResultInfoBlock)resultInfo{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[paramters keyValues]];
    
    NSMutableArray *dataList = [NSMutableArray array];
    NSInteger index = 0;
    NSString *imageName = @"";
    for (ZLPhotoAssets *assest in imageList) {
        index++;
        if ([assest isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)assest;
            NSArray *array = [str componentsSeparatedByString:@"/"];
            array = [[array lastObject] componentsSeparatedByString:@"-"];
            imageName =[imageName stringByAppendingString:[array firstObject]];
            imageName = [imageName stringByAppendingString:@".png_"];
            continue;
        }
        HttpImage *httpImage = [[HttpImage alloc]init];
        UIImage *originalImage = [[assest originImage] fixOrientation]; // 重要的，否则上传到服务端图片会倒转
        NSData *orignalImageData = UIImageJPEGRepresentation(originalImage, 0.5);
        DLog(@"%ld",orignalImageData.length);
        httpImage.data = orignalImageData;
        httpImage.name = [NSString stringWithFormat:@"pic%ld",index];
        httpImage.fileName = [NSString stringWithFormat:@"pic%ld.png",index];
        [dataList addObject:httpImage];
    }
    
    
    if (dataList.count == 0) {
        if (imageName.length > 0) {
            dict[@"images"] = imageName;
        }
        [HttpTool postWithSessionClient:@"CustomWarnAddForGA" param:dict success:^(id JSON) {
            resultInfo(YES,JSON);
        } failure:^(NSError *error) {
            resultInfo(NO,error);
        }];
    }else{
        [self uploadImage:dataList Success:^(id JSON) {
            NSString *images = imageName;
            for (NSDictionary *dict in JSON) {
                images = [images stringByAppendingString:dict[@"image"]];
                if (dict != [JSON lastObject]){
                    images = [images stringByAppendingString:@"_"];
                }
            }
            if (images.length > 0) {
                dict[@"images"] = images;
            }
            
            [HttpTool postWithSessionClient:@"CustomWarnAddForGA" param:dict success:^(id JSON) {
                resultInfo(YES,JSON);
            } failure:^(NSError *error) {
                resultInfo(NO,error);
            }];
            
        } Failure:^(NSError *error) {
            [AlertTool showAlertToolWithMessage:@"图片上传失败，请重新提交"];
        }];
    }
}

+(void)uploadImage:(NSArray *)imageList Success:(SuccessBlock)success Failure:(FailureBlock)failure{
    [HttpTool uploadImageWithUrl:@"PhotoUpload" httpImages:imageList param:@{@"qqfile":@"hihihihi.jpg"} Success:^(id JSON) {
        success(JSON[@"images"]);
    } Failure:^(NSError *error) {
        DLog(@"%@",error);
        failure(error);
    }];
}

+ (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [original drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return final;
}

#pragma mark - Core Data 操作

+ (double)newestTimeAtIntelligenceColumnType:(IntelligenceColumnType)columnType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = nil;
    switch (columnType){
        case IntelligenceColumnInstant:
            key = @"Instant";
            break;
            
        case IntelligenceColumnDaily:
            key = @"Daily";
            break;
            
        case IntelligenceColumnInternational:
            key = @"International";
            break;
            
        case IntelligenceColumnAllIntelligence:
            key = @"AllIntelligence";
            break;
            
        default:
            key = @"";
            break;
    }
    key = [key stringByAppendingFormat:@"_intelligence_%@", [VEUtility currentUserName]];
    
    return [defaults doubleForKey:key];
}

+ (void)setNewestTime:(double)newTimeReply atIntelligenceColumnType:(IntelligenceColumnType)columnType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = nil;
    switch (columnType){
        case IntelligenceColumnInstant:
            key = @"Instant";
            break;
            
        case IntelligenceColumnDaily:
            key = @"Daily";
            break;
            
        case IntelligenceColumnInternational:
            key = @"International";
            break;
            
        case IntelligenceColumnAllIntelligence:
            key = @"AllIntelligence";
            break;
            
        default:
            key = @"";
            break;
    }
    key = [key stringByAppendingFormat:@"_intelligence_%@", [VEUtility currentUserName]];
    
    [defaults setDouble:newTimeReply forKey:key];
    [defaults synchronize];
}



+ (NSDictionary *)intelligenceInfoInBoxType:(BoxType)boxType
                              withArticleID:(NSString *)articleId
                                andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0){
        return nil;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    Intelligence *intelligObj = [self retrieveIntelligenceObjectInBoxType:boxType
                                                                 withArticleID:articleId
                                                                   andWarnType:warnType];
    if (intelligObj){
        [info setValue:intelligObj.isRead             forKey:kIntelligenceIsRead];
        [info setValue:intelligObj.isReadMarkUpload    forKey:kIntelligenceIsReadMarkUpload];
        [info setValue:intelligObj.latestTimeReply     forKey:kIntelligenceLatestTimeReply];
    }else{
        [info setValue:[NSNumber numberWithBool:NO]    forKey:kIntelligenceIsRead];
        [info setValue:[NSNumber numberWithBool:NO]    forKey:kIntelligenceIsReadMarkUpload];
        [info setValue:[NSNumber numberWithDouble:0]   forKey:kIntelligenceLatestTimeReply];
    }
    return info;
}

+ (void)setIntelligenceInfo:(NSDictionary *)info
                  InBoxType:(BoxType)boxType
              withArticleID:(NSString *)articleId
                andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0 || info == nil){
        return;
    }
    
    Intelligence *intelligObj = [self retrieveIntelligenceObjectInBoxType:boxType
                                                                 withArticleID:articleId
                                                                   andWarnType:warnType];
    if (intelligObj){
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSNumber *numIsRead = [info valueForKey:kIntelligenceIsRead];
        if (numIsRead){
            intelligObj.isRead = [NSNumber numberWithBool:[numIsRead boolValue]];
        }
        
        NSNumber *numReadMarkUpload = [info valueForKey:kIntelligenceIsReadMarkUpload];
        if (numReadMarkUpload){
            intelligObj.isReadMarkUpload = [NSNumber numberWithBool:[numReadMarkUpload boolValue]];
        }
        
        NSNumber *numLatestTimeReply = [info valueForKey:kIntelligenceLatestTimeReply];
        if (numLatestTimeReply){
            intelligObj.latestTimeReply = numLatestTimeReply;
        }
        
        NSError *error = nil;
        [context save:&error];
    }else{
        [self createIntelligenceObjWithInfo:info
                                       InBoxType:boxType
                                   withArticleID:articleId
                                     andWarnType:warnType];
    }
}

+ (Intelligence *)retrieveIntelligenceObjectInBoxType:(BoxType)boxType
                                        withArticleID:(NSString *)articleId
                                          andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0){
        return nil;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"Intelligence"
                                                      inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityWarnDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((boxType=%d) AND (articleId=%@) AND (warnType=%d))", boxType, articleId, warnType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil){
        if ([fetchedObjects count] > 0){
            return [fetchedObjects objectAtIndex:0];
        }
    }
    return nil;
}

+ (void)createIntelligenceObjWithInfo:(NSDictionary *)info
                            InBoxType:(BoxType)boxType
                        withArticleID:(NSString *)articleId
                          andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0 || info == nil){
        return;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    Intelligence *intelligObj = [NSEntityDescription insertNewObjectForEntityForName:@"Intelligence"
                                                              inManagedObjectContext:context];
    
    NSNumber *numIsRead = [info valueForKey:kIntelligenceIsRead];
    if (numIsRead){
        intelligObj.isRead = [NSNumber numberWithBool:[numIsRead boolValue]];
    }else{
        intelligObj.isRead = [NSNumber numberWithBool:NO];
    }
    
    NSNumber *numReadMarkUpload = [info valueForKey:kIntelligenceIsReadMarkUpload];
    if (numReadMarkUpload){
        intelligObj.isReadMarkUpload = [NSNumber numberWithBool:[numReadMarkUpload boolValue]];
    }else{
        intelligObj.isReadMarkUpload = [NSNumber numberWithBool:NO];
    }
    
    NSNumber *numLatestTimeReply = [info valueForKey:kIntelligenceLatestTimeReply];
    if (numLatestTimeReply){
        intelligObj.latestTimeReply = numLatestTimeReply;
    }else{
        intelligObj.latestTimeReply = [NSNumber numberWithDouble:0];
    }
    
    intelligObj.boxType         = [NSNumber numberWithInteger:boxType];
    intelligObj.articleId       = articleId;
    intelligObj.warnType        = [NSNumber numberWithInteger:warnType];
    intelligObj.firstTimeRead   = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
    
    NSError *error = nil;
    [context save:&error];
    if (error){
        NSLog(@"--- create Intelligence Failed. articleId=%@, warnType=%ld ---", articleId, (long)warnType);
    }
}


@end

