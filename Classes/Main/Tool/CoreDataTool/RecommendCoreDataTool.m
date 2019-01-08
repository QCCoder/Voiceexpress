//
//  SQLTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "RecommendCoreDataTool.h"

@implementation RecommendCoreDataTool

#pragma mark 推荐阅读
/**
 *  获取推荐阅读本地columnId，用于判断是否已读
 */
+ (NSInteger)newestColumnActicleIdInColumn:(NSString *)columnId withUserName:(NSString *)userName
{
    @autoreleasepool {
        if (columnId.length == 0 || userName.length == 0)
        {
            return 0;
        }
        
        NSInteger newestArticleId = 0;
        RecommendColumn *columnObj = [RecommendCoreDataTool retrieveRecommendColumnObjectInColumn:columnId
                                                                                 withUserName:userName];
        if (columnObj)
        {
            newestArticleId = [columnObj.newestArticleId integerValue];
        }
        return newestArticleId;
    }
}
/**
 *  保存ArticleId
 */
+ (void)setNewestColumnActicleId:(NSInteger)newestArticleId InColumn:(NSString *)columnId withUserName:(NSString *)userName
{
    @autoreleasepool {
        if (columnId.length == 0 || userName.length == 0)
        {
            return;
        }
        
        RecommendColumn *columnObj = [RecommendCoreDataTool retrieveRecommendColumnObjectInColumn:columnId
                                                                         withUserName:userName];
        if (columnObj)
        {
            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            columnObj.newestArticleId = [NSNumber numberWithInteger:newestArticleId];
            NSError *error = nil;
            [context save:&error];
        }
        else
        {
            [RecommendCoreDataTool createRecommendColumnObjectInColumn:columnId
                                              withUserName:userName
                                        andNewestArticleId:newestArticleId];
            
        }
    }
}

/**
 *  从获取本地数据库，推荐阅读数据
 */
+ (RecommendColumn *)retrieveRecommendColumnObjectInColumn:(NSString *)columnId
                                              withUserName:(NSString *)userName
{
    if (columnId.length == 0 || userName.length == 0)
    {
        return nil;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"RecommendColumn"
                                                      inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityWarnDesc];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"((columnId=%@) AND (userName=%@))", columnId, userName];        [fetchRequest setPredicate:predicate];
    
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

/**
 *  把推荐阅读数据保存到本地
 *
 */
+ (void)createRecommendColumnObjectInColumn:(NSString *)columnId
                               withUserName:(NSString *)userName
                         andNewestArticleId:(NSInteger)newestArticleId
{
    if (columnId.length == 0 || userName.length == 0)
    {
        return;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    RecommendColumn *columnObj = [NSEntityDescription insertNewObjectForEntityForName:@"RecommendColumn"
                                                               inManagedObjectContext:context];
    
    columnObj.columnId          = columnId;
    columnObj.userName          = userName;
    columnObj.newestArticleId   = [NSNumber numberWithInteger:newestArticleId];
    
    NSError *error = nil;
    [context save:&error];
    if (error)
    {
        NSLog(@"--- create RecommendColumn Entity Failed. columnId=%@, userName=%@ ---", columnId, userName);
    }
}

@end
