//
//  RecommendReadTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "RecommendReadTool.h"

@implementation RecommendReadTool

+(void)doFavoriteWithUrl:(NSString *)url param:(NSDictionary *)param success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [HttpTool postWithSessionClient:url param:param success:^(id JSON) {
        success(JSON);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+(void)loadSectionListSuccess:(ResultInfoBlock)resultInfo
{
    [HttpTool postWithSessionClient:@"sectionListForGA" param:nil success:^(id JSON) {
        NSArray *array = [RecommendColumnAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)loadSectionWithParam:(NSDictionary *)param columnID:(NSString *)columnID resultInfo:(ResultInfoBlock)resultInfo
{
    [HttpTool postWithSessionClient:@"section" param:param success:^(id JSON) {
        NSArray *datalist = [RecommendAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
        NSMutableArray *array = [NSMutableArray array];
        for (RecommendAgent *agent in datalist) {
            agent.isRead = [self isRecommendReadInColumn:columnID
                                           withArticleId:agent.articleId
                                             andWarnType:agent.warnType];
            [array addObject:agent];
        }
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+ (BOOL)isRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    @autoreleasepool {
        if (columnId.length == 0 || articleId.length == 0)
        {
            return NO;
        }
        
        BOOL isRead = NO;
        RecommendRead *recommendObj = [self retrieveRecommendReadObjectInColumn:columnId
                                                                       withArticleId:articleId
                                                                         andWarnType:warnType];
        if (recommendObj)
        {
            isRead = [recommendObj.isRead boolValue];
        }
        //        else
        //        {
        //            [VEUtility createRecommendReadObjectInColumn:columnId
        //                                           withArticleId:articleId
        //                                             andWarnType:warnType
        //                                                  isRead:NO];
        //        }
        return isRead;
    }
}

+ (void)setRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    @autoreleasepool {
        if (columnId.length == 0 || articleId.length == 0)
        {
            return;
        }
        
        RecommendRead *recommendObj = [self retrieveRecommendReadObjectInColumn:columnId
                                                                       withArticleId:articleId
                                                                         andWarnType:warnType];
        if (recommendObj)
        {
            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            recommendObj.isRead = [NSNumber numberWithBool:YES];
            NSError *error = nil;
            [context save:&error];
        }
        else
        {
            [self createRecommendReadObjectInColumn:columnId
                                           withArticleId:articleId
                                             andWarnType:warnType
                                                  isRead:YES];
        }
    }
}

+ (void)createRecommendReadObjectInColumn:(NSString *)columnId
                            withArticleId:(NSString *)articleId
                              andWarnType:(NSInteger)warnType
                                   isRead:(BOOL)isRead
{
    @autoreleasepool {
        if (columnId.length == 0 || articleId.length == 0)
        {
            return;
        }
        
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        RecommendRead *recommendObj = [NSEntityDescription insertNewObjectForEntityForName:@"RecommendRead"
                                                                    inManagedObjectContext:context];
        recommendObj.columnId        = columnId;
        recommendObj.articleId       = articleId;
        recommendObj.warnType        = [NSNumber numberWithInteger:warnType];
        recommendObj.isRead          = [NSNumber numberWithBool:isRead];
        recommendObj.firstTimeRead   = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
        
        NSError *error = nil;
        [context save:&error];
        if (error)
        {
            NSLog(@"--- create RecommendRead Entity Failed. aid=%@, warnType=%ld ---", articleId, (long)warnType);
        }
    }
}


+ (RecommendRead *)retrieveRecommendReadObjectInColumn:(NSString *)columnId
                                         withArticleId:(NSString *)articleId
                                           andWarnType:(NSInteger)warnType
{
    if (columnId.length == 0 || articleId.length == 0)
    {
        return nil;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"RecommendRead"
                                                      inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityWarnDesc];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"((columnId=%@) AND (articleId=%@) AND (warnType=%d))", columnId, articleId, warnType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil)
    {
        if ([fetchedObjects count] > 0)
        {
            return [fetchedObjects objectAtIndex:0];
        }
    }
    return nil;
}

@end
