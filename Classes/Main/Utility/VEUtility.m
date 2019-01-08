//
//  VEUtility.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-13.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEUtility.h"

#import <CommonCrypto/CommonDigest.h>

#import <UIKit/UIKit.h>
#import "VEAppDelegate.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

//#import "CoreTelephony.h"

#import "VELatestAlertViewController.h"
#import "VERecommendReadViewController.h"
#import "VEMessageViewController.h"
#import "QCDeviceViewController.h"
#import "FYNHttpRequestLoader.h"
// core data entity
#import "Warn.h"
#import "RecommendRead.h"
#import "Intelligence.h"
#import "RecommendColumn.h"

#import "STKeychain.h"
#import "OpenUDID.h"
#import <AdSupport/AdSupport.h>

//

#import "VERecommendColumnTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "VEShowMoreTableViewCell.h"
#import "VEShowNoResultsTableViewCell.h"
#import "VETokenTool.h"

#import "QCDeviceViewController.h"
static NSString * const kUserName               = @"VEUserName";
static NSString * const kUserId                 = @"kUserId";
static NSString * const kFirstLogin             = @"kFirstLogin";
static NSString * const kUserMobileToken        = @"kUserMobileToken";
static NSString * const kUserOpenToken          = @"kUserOpenToken";
static NSString * const kUserServiceTime        = @"kUserServiceTime";
static NSString * const kUserPassword           = @"VEPassWord";
static NSString * const kAPNSToken              = @"VEApnsToken";
static NSString * const kAutoLogin              = @"VEAutologin";
static NSString * const kFailedClearBadge       = @"VEFailedClearBadge";

static NSString * const kVEDeviceLockTime       = @"VEDeviceLockTime";
static NSString * const kVEDeviceLockPassword   = @"VEDeviceLockPassword";
static NSString * const kVEDeviceLockActivated  = @"VEDeviceLockActivated";
static NSString * const kVEDeviceLockErrorTimes = @"VEDeviceLockErrorTimes";

static NSString * const kVEShouldReceivePictureOnCell = @"VEShouldReceivePictureOnCell";
static NSString * const kVEMacAddress = @"VEMacAddress";
static NSString * const kVEDeviceIMEI = @"VEDeviceIMEI";

static NSString * const kVESortableTipView      = @"VESortableTipView";
static NSString * const kVEContentViewFontSize  = @"VEContentViewFontSize";

extern NSString  *sessionToken;
extern NSInteger currentUserID;
extern BOOL      isTopLeader;
extern BOOL      isDefaultPassword;
extern BOOL      isSecurityCtrlOpen;
extern BOOL      isLockCtrlOpen;
extern BOOL      isIntelligenceNeedWhole;
extern BOOL      networkReportReview;

static const NSInteger k10MImageDataSize = 10 * 1024 * 1024;
static const NSInteger k8MImageDataSize = 8 * 1024 * 1024;
static const NSInteger k4MImageDataSize = 4 * 1024 * 1024;
static const NSInteger k3MImageDataSize = 3 * 1024 * 1024;
static const NSInteger k2MImageDataSize = 2 * 1024 * 1024;
static const NSInteger k1MImageDataSize = 1 * 1024 * 1024;

extern BOOL g_IsMessageOnRed;
extern BOOL g_IsLatestAlertOnRed;
extern BOOL g_IsRecommendReadOnRed;
extern BOOL g_IsInternetAlertOnRed;
extern BOOL g_IsInformReviewOnRed;

static NSString * const kUMSAgent           = @"CYYUNUMSAgent";
static NSString * const kUMSAgentUDID       = @"CYYUNUMSAgentUDID";

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface VEUtility()
{
    dispatch_queue_t synQueue;
}

- (void)directSeverToClearBadgeValue;

- (void)directSeverToLogout;

@end

@implementation VEUtility

- (id)init
{
    self = [super init];
    if (self)
    {
        synQueue = dispatch_queue_create("com.cyyun.syncQueue", NULL);
    }
    return self;
}

+ (VEUtility *)sharedInstance
{
    static VEUtility *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VEUtility alloc] init];
    });
    return instance;
}

// 获取当前程序的版本号
+ (NSString *)curAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return version;
}

// 判别是否连接网络
+ (BOOL)isNetworkReachable
{
    // Create zero address
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Could not recover network flags.");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN))
    {
        needsConnection = NO;
    }
    
    return ((isReachable && !needsConnection) ? YES : NO);
}

// 判别当前网络是否为Wifi
+ (BOOL)isCurrentNetworkWifi
{
    BOOL bResult = YES;
    Reachability *r = [Reachability reachabilityForLocalWiFi];
    if ( [r currentReachabilityStatus] != ReachableViaWiFi)
    {
        bResult = NO;
        NSLog(@"--- none Wifi ---");
    }
    else
    {
        NSLog(@"--- Wifi ---");
    }
    
    
    return bResult;
}

+ (NSInteger)selectedIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults integerForKey:@"selectedIndex"];
}

// 判别是否需要自动登陆
+ (BOOL)shouldAutoLoginToServer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults boolForKey:kAutoLogin];
}

+ (void)setShouldAutoLoginToServer:(BOOL)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:kAutoLogin];
    [defaults synchronize];
}

+ (BOOL)shouldReceivePictureOnCellNetwork
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@", kVEShouldReceivePictureOnCell, [VEUtility currentUserName]];
    return [defaults boolForKey:key];
}

+ (void)setShouldReceivePictureOnCellNetwork:(BOOL)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@", kVEShouldReceivePictureOnCell, [VEUtility currentUserName]];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
}

//////////////////////////////////////////////////////////////////////////////////////

+ (Warn *)retrieveWarnObjectWithArticleId:(NSString *)articleId
                              andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0)
    {
        return nil;
    }
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"Warn"
                                                      inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityWarnDesc];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"((articleId=%@) AND (warnType=%d))", articleId, warnType];
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

//+ (RecommendRead *)retrieveRecommendReadObjectInColumn:(NSString *)columnId
//                                         withArticleId:(NSString *)articleId
//                                           andWarnType:(NSInteger)warnType
//{
//    if (columnId.length == 0 || articleId.length == 0)
//    {
//        return nil;
//    }
//    
//    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"RecommendRead"
//                                                      inManagedObjectContext:context];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entityWarnDesc];
//    
//    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"((columnId=%@) AND (articleId=%@) AND (warnType=%d))", columnId, articleId, warnType];
//    [fetchRequest setPredicate:predicate];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects != nil)
//    {
//        if ([fetchedObjects count] > 0)
//        {
//            return [fetchedObjects objectAtIndex:0];
//        }
//    }
//    return nil;
//}

//+ (RecommendColumn *)retrieveRecommendColumnObjectInColumn:(NSString *)columnId
//                                              withUserName:(NSString *)userName
//{
//    if (columnId.length == 0 || userName.length == 0)
//    {
//        return nil;
//    }
//    
//    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"RecommendColumn"
//                                                      inManagedObjectContext:context];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entityWarnDesc];
//    
//    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"((columnId=%@) AND (userName=%@))", columnId, userName];        [fetchRequest setPredicate:predicate];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects != nil)
//    {
//        if ([fetchedObjects count] > 0)
//        {
//            return [fetchedObjects objectAtIndex:0];
//        }
//    }
//    return nil;
//}

//+ (Intelligence *)retrieveIntelligenceObjectInBoxType:(BoxType)boxType
//                                        withArticleID:(NSString *)articleId
//                                          andWarnType:(NSInteger)warnType
//{
//    if (articleId.length == 0)
//    {
//        return nil;
//    }
//    
//    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSEntityDescription *entityWarnDesc = [NSEntityDescription entityForName:@"Intelligence"
//                                                      inManagedObjectContext:context];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entityWarnDesc];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((boxType=%d) AND (articleId=%@) AND (warnType=%d))", boxType, articleId, warnType];
//    [fetchRequest setPredicate:predicate];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects != nil)
//    {
//        if ([fetchedObjects count] > 0)
//        {
//            return [fetchedObjects objectAtIndex:0];
//        }
//    }
//    return nil;
//}

+ (void)createWarnObjectWithArticleId:(NSString *)articleId
                          andWarnType:(NSInteger)warnType
                               isRead:(BOOL)isRead
                       articleContent:(NSString *)content
{
    @autoreleasepool {
        if (articleId.length == 0)
        {
            return;
        }
        
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        Warn *warnObj = [NSEntityDescription insertNewObjectForEntityForName:@"Warn"
                                                      inManagedObjectContext:context];
        warnObj.articleId       = articleId;
        warnObj.warnType        = [NSNumber numberWithInteger:warnType];
        warnObj.isRead          = [NSNumber numberWithBool:isRead];
        warnObj.firstTimeRead   = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
        if (content)
        {
            warnObj.articleContent = content;
        }
        
        NSError *error = nil;
        [context save:&error];
        if (error)
        {
            NSLog(@"--- create Warn Entity Failed. aid=%@, warnType=%ld ---", articleId, (long)warnType);
        }
    }
}

//+ (void)createRecommendReadObjectInColumn:(NSString *)columnId
//                            withArticleId:(NSString *)articleId
//                              andWarnType:(NSInteger)warnType
//                                   isRead:(BOOL)isRead
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || articleId.length == 0)
//        {
//            return;
//        }
//        
//        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSManagedObjectContext *context = [appDelegate managedObjectContext];
//        RecommendRead *recommendObj = [NSEntityDescription insertNewObjectForEntityForName:@"RecommendRead"
//                                                                    inManagedObjectContext:context];
//        recommendObj.columnId        = columnId;
//        recommendObj.articleId       = articleId;
//        recommendObj.warnType        = [NSNumber numberWithInteger:warnType];
//        recommendObj.isRead          = [NSNumber numberWithBool:isRead];
//        recommendObj.firstTimeRead   = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
//        
//        NSError *error = nil;
//        [context save:&error];
//        if (error)
//        {
//            NSLog(@"--- create RecommendRead Entity Failed. aid=%@, warnType=%ld ---", articleId, (long)warnType);
//        }
//    }
//}

//+ (void)createRecommendColumnObjectInColumn:(NSString *)columnId
//                               withUserName:(NSString *)userName
//                         andNewestArticleId:(NSInteger)newestArticleId
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || userName.length == 0)
//        {
//            return;
//        }
//        
//        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSManagedObjectContext *context = [appDelegate managedObjectContext];
//        RecommendColumn *columnObj = [NSEntityDescription insertNewObjectForEntityForName:@"RecommendColumn"
//                                                                   inManagedObjectContext:context];
//        
//        columnObj.columnId          = columnId;
//        columnObj.userName          = userName;
//        columnObj.newestArticleId   = [NSNumber numberWithInteger:newestArticleId];
//        
//        NSError *error = nil;
//        [context save:&error];
//        if (error)
//        {
//            NSLog(@"--- create RecommendColumn Entity Failed. columnId=%@, userName=%@ ---", columnId, userName);
//        }
//    }
//}

//+ (void)createIntelligenceObjWithInfo:(NSDictionary *)info
//                            InBoxType:(BoxType)boxType
//                        withArticleID:(NSString *)articleId
//                          andWarnType:(NSInteger)warnType
//{
//    @autoreleasepool {
//        if (articleId.length == 0 || info == nil)
//        {
//            return;
//        }
//        
//        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSManagedObjectContext *context = [appDelegate managedObjectContext];
//        Intelligence *intelligObj = [NSEntityDescription insertNewObjectForEntityForName:@"Intelligence"
//                                                                  inManagedObjectContext:context];
//        
//        NSNumber *numIsRead = [info valueForKey:kIntelligenceIsRead];
//        if (numIsRead)
//        {
//            intelligObj.isRead = [NSNumber numberWithBool:[numIsRead boolValue]];
//        }
//        else
//        {
//            intelligObj.isRead = [NSNumber numberWithBool:NO];
//        }
//        
//        NSNumber *numReadMarkUpload = [info valueForKey:kIntelligenceIsReadMarkUpload];
//        if (numReadMarkUpload)
//        {
//            intelligObj.isReadMarkUpload = [NSNumber numberWithBool:[numReadMarkUpload boolValue]];
//        }
//        else
//        {
//            intelligObj.isReadMarkUpload = [NSNumber numberWithBool:NO];
//        }
//        
//        NSNumber *numLatestTimeReply = [info valueForKey:kIntelligenceLatestTimeReply];
//        if (numLatestTimeReply)
//        {
//            intelligObj.latestTimeReply = numLatestTimeReply;
//        }
//        else
//        {
//            intelligObj.latestTimeReply = [NSNumber numberWithDouble:0];
//        }
//        
//        intelligObj.boxType         = [NSNumber numberWithInteger:boxType];
//        intelligObj.articleId       = articleId;
//        intelligObj.warnType        = [NSNumber numberWithInteger:warnType];
//        intelligObj.firstTimeRead   = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
//        
//        NSError *error = nil;
//        [context save:&error];
//        if (error)
//        {
//            NSLog(@"--- create Intelligence Failed. articleId=%@, warnType=%ld ---", articleId, (long)warnType);
//        }
//    }
//}


+ (BOOL)isWarnReadWithArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    @autoreleasepool {
        if (articleId.length == 0)
        {
            return NO;
        }
        
        BOOL isRead = NO;
        Warn *warnObj = [VEUtility retrieveWarnObjectWithArticleId:articleId andWarnType:warnType];
        if (warnObj)
        {
            isRead = [warnObj.isRead boolValue];
        }
        //        else
        //        {
        //            [VEUtility createWarnObjectWithArticleId:articleId andWarnType:warnType isRead:NO articleContent:nil];
        //        }
        
        return isRead;
    }
}

+ (void)setWarnReadWithArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    @autoreleasepool {
        if (articleId.length == 0)
        {
            return;
        }
        
        Warn *warnObj = [VEUtility retrieveWarnObjectWithArticleId:articleId andWarnType:warnType];
        if (warnObj)
        {
            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            warnObj.isRead = [NSNumber numberWithBool:YES];
            NSError *error = nil;
            [context save:&error];
        }
        else
        {
            [VEUtility createWarnObjectWithArticleId:articleId andWarnType:warnType isRead:YES articleContent:nil];
        }
    }
}

+ (NSString *)retrieveWarnContentWithArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    if (articleId.length == 0)
    {
        return nil;
    }
    
    Warn *warnObj = [VEUtility retrieveWarnObjectWithArticleId:articleId andWarnType:warnType];
    if (warnObj)
    {
        return warnObj.articleContent;
    }
    return nil;
}

+ (void)setWarnArticleContent:(NSString *)content withArticleID:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    @autoreleasepool {
        if (content.length == 0 || articleId.length == 0)
        {
            return;
        }
        
        Warn *warnObj = [VEUtility retrieveWarnObjectWithArticleId:articleId andWarnType:warnType];
        if (warnObj)
        {
            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            warnObj.articleContent = content;
            NSError *error = nil;
            [context save:&error];
        }
        else
        {
            [VEUtility createWarnObjectWithArticleId:articleId andWarnType:warnType isRead:YES articleContent:content];
        }
    }
}

//+ (BOOL)isRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || articleId.length == 0)
//        {
//            return NO;
//        }
//        
//        BOOL isRead = NO;
//        RecommendRead *recommendObj = [VEUtility retrieveRecommendReadObjectInColumn:columnId
//                                                                       withArticleId:articleId
//                                                                         andWarnType:warnType];
//        if (recommendObj)
//        {
//            isRead = [recommendObj.isRead boolValue];
//        }
//        //        else
//        //        {
//        //            [VEUtility createRecommendReadObjectInColumn:columnId
//        //                                           withArticleId:articleId
//        //                                             andWarnType:warnType
//        //                                                  isRead:NO];
//        //        }
//        return isRead;
//    }
//}
//
//+ (void)setRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || articleId.length == 0)
//        {
//            return;
//        }
//        
//        RecommendRead *recommendObj = [VEUtility retrieveRecommendReadObjectInColumn:columnId
//                                                                       withArticleId:articleId
//                                                                         andWarnType:warnType];
//        if (recommendObj)
//        {
//            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//            NSManagedObjectContext *context = [appDelegate managedObjectContext];
//            
//            recommendObj.isRead = [NSNumber numberWithBool:YES];
//            NSError *error = nil;
//            [context save:&error];
//        }
//        else
//        {
//            [VEUtility createRecommendReadObjectInColumn:columnId
//                                           withArticleId:articleId
//                                             andWarnType:warnType
//                                                  isRead:YES];
//        }
//    }
//}

//+ (NSInteger)newestColumnActicleIdInColumn:(NSString *)columnId withUserName:(NSString *)userName
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || userName.length == 0)
//        {
//            return 0;
//        }
//        
//        NSInteger newestArticleId = 0;
//        RecommendColumn *columnObj = [VEUtility retrieveRecommendColumnObjectInColumn:columnId
//                                                                         withUserName:userName];
//        if (columnObj)
//        {
//            newestArticleId = [columnObj.newestArticleId integerValue];
//        }
//        return newestArticleId;
//    }
//}

//+ (void)setNewestColumnActicleId:(NSInteger)newestArticleId InColumn:(NSString *)columnId withUserName:(NSString *)userName
//{
//    @autoreleasepool {
//        if (columnId.length == 0 || userName.length == 0)
//        {
//            return;
//        }
//        
//        RecommendColumn *columnObj = [VEUtility retrieveRecommendColumnObjectInColumn:columnId
//                                                                         withUserName:userName];
//        if (columnObj)
//        {
//            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//            NSManagedObjectContext *context = [appDelegate managedObjectContext];
//            
//            columnObj.newestArticleId = [NSNumber numberWithInteger:newestArticleId];
//            NSError *error = nil;
//            [context save:&error];
//        }
//        else
//        {
//            [VEUtility createRecommendColumnObjectInColumn:columnId
//                                              withUserName:userName
//                                        andNewestArticleId:newestArticleId];
//            
//        }
//    }
//}

//+ (NSDictionary *)intelligenceInfoInBoxType:(BoxType)boxType
//                              withArticleID:(NSString *)articleId
//                                andWarnType:(NSInteger)warnType
//{
//    if (articleId.length == 0)
//    {
//        return nil;
//    }
//    
//    NSMutableDictionary *info = [NSMutableDictionary dictionary];
//    Intelligence *intelligObj = [VEUtility retrieveIntelligenceObjectInBoxType:boxType
//                                                                 withArticleID:articleId
//                                                                   andWarnType:warnType];
//    if (intelligObj)
//    {
//        [info setValue:intelligObj.isRead             forKey:kIntelligenceIsRead];
//        [info setValue:intelligObj.isReadMarkUpload    forKey:kIntelligenceIsReadMarkUpload];
//        [info setValue:intelligObj.latestTimeReply     forKey:kIntelligenceLatestTimeReply];
//    }
//    else
//    {
//        [info setValue:[NSNumber numberWithBool:NO]    forKey:kIntelligenceIsRead];
//        [info setValue:[NSNumber numberWithBool:NO]    forKey:kIntelligenceIsReadMarkUpload];
//        [info setValue:[NSNumber numberWithDouble:0]   forKey:kIntelligenceLatestTimeReply];
//        
//        //        [VEUtility createIntelligenceObjWithInfo:info
//        //                                       InBoxType:boxType
//        //                                   withArticleID:articleId
//        //                                     andWarnType:warnType];
//    }
//    return info;
//}
//
//+ (void)setIntelligenceInfo:(NSDictionary *)info
//                  InBoxType:(BoxType)boxType
//              withArticleID:(NSString *)articleId
//                andWarnType:(NSInteger)warnType
//{
//    @autoreleasepool {
//        if (articleId.length == 0 || info == nil)
//        {
//            return;
//        }
//        
//        Intelligence *intelligObj = [VEUtility retrieveIntelligenceObjectInBoxType:boxType
//                                                                     withArticleID:articleId
//                                                                       andWarnType:warnType];
//        if (intelligObj)
//        {
//            VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
//            NSManagedObjectContext *context = [appDelegate managedObjectContext];
//            
//            NSNumber *numIsRead = [info valueForKey:kIntelligenceIsRead];
//            if (numIsRead)
//            {
//                intelligObj.isRead = [NSNumber numberWithBool:[numIsRead boolValue]];
//            }
//            
//            NSNumber *numReadMarkUpload = [info valueForKey:kIntelligenceIsReadMarkUpload];
//            if (numReadMarkUpload)
//            {
//                intelligObj.isReadMarkUpload = [NSNumber numberWithBool:[numReadMarkUpload boolValue]];
//            }
//            
//            NSNumber *numLatestTimeReply = [info valueForKey:kIntelligenceLatestTimeReply];
//            if (numLatestTimeReply)
//            {
//                intelligObj.latestTimeReply = numLatestTimeReply;
//            }
//            
//            NSError *error = nil;
//            [context save:&error];
//        }
//        else
//        {
//            [VEUtility createIntelligenceObjWithInfo:info
//                                           InBoxType:boxType
//                                       withArticleID:articleId
//                                         andWarnType:warnType];
//        }
//    }
//}


//////////////////////////////////////////////////////////////////////////////////////


// 检测版本更新
+ (NSDictionary *)checkNewVersion
{
    NSString *stringUrl = [NSString stringWithFormat:@"%@/ClientVersionCheck", kBaseURL];
    NSURL *checkUrl = [NSURL URLWithString:stringUrl];
    
    NSString *version = [self curAppVersion];
    NSString *paramsStr = @"device=iga&checkType=auto&";
    paramsStr = [paramsStr stringByAppendingFormat:@"version=%@", version];
    
    FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    NSData *receiveData = [httpRequestLoader startSynRequestWithURL:checkUrl withParams:paramsStr withTimeOut:20];
    
    NSInteger res = 11;
    BOOL bMandatory = NO;
    NSString *updateDiscrip = @"";
    
    if (receiveData)
    {
        NSError *error = nil;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if (resultDic == nil)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else
        {
            if ([resultDic count] <= 0)
            {
                NSLog(@"服务器返回的数据格式错误: %@.", resultDic);
            }
            else
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
                if ([jsonParser retrieveRusultValue] == 10)
                {
                    res = 10;
                    bMandatory = [jsonParser retrieveMandatoryUpdateValue];
                    updateDiscrip = [jsonParser retrieveUpdateDiscriptionValue];
                    
                    NSLog(@"--- have new version. ---");
                }
            }
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInteger:res], kHasNewVersion,
                         [NSNumber numberWithBool:bMandatory], kMandatoryUpdate,
                         updateDiscrip, kUpdateDiscription, nil];
    
    if (res == 11)
    {
        NSLog(@"--- no new version. ---");
    }
    
    return dic;
}

// url编码
+ (NSString *)encodeToPercentEscapeString:(NSString *)input
{
    NSString *output = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)input, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return output;
}

// 下载最新版本
+ (void)downLoadNewVersion
{
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *updateString = [NSString stringWithFormat:@"%@/ClientVersionUpdate?device=iga", kBaseURL];
    NSURL *updateUrl = [NSURL URLWithString:updateString];
    NSLog(@"updateUrl: %@", updateUrl);
    if ([app canOpenURL:updateUrl] == YES)
    {
        [app openURL:updateUrl];
    }
    else
    {
        NSLog(@"no application is available that will accept the update URL.");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"更新提示"
                                                       message:@"您的设备不支持打开更新链接"
                                                      delegate:nil
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

// 注册Apns推送
+ (void)registerForRemoteNotifications
{
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings * s =[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication]registerUserNotificationSettings:s];
        [[UIApplication sharedApplication]registerForRemoteNotifications];
    } else{ // ios7
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge                                       |UIRemoteNotificationTypeSound                                      |UIRemoteNotificationTypeAlert)];
    }
}

// 注销Apns推送
+ (void)unregisterForRemoteNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

// 显示指定的错误信息
+ (void)showServerErrorMeassage:(NSString *)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    [alert show];
}

// 切换至登录界面
+ (void)returnToLoginInterface:(BOOL)bShowAlert
{
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[RESideMenu class]])
    {
        appDelegate.launchFromWarnRemoteNotification = NO;
        appDelegate.launchFromRecommendReadRemoteNotification = NO;
        
        // 注销APNS推送
        [self unregisterForRemoteNotifications];
        
        [VEUtility setShouldAutoLoginToServer:NO];
        
        //取消手机令牌
        [VEUtility setCurrentIsopenToken:@"0"];
        [VEUtility setCurrentMobileToken:@""];
        [VEUtility setCurrentServiceTime:@"0"];
        [VEUtility setCurrentUserId:@"0"];
        [VEUtility setIsFirstLogin:@"0"];
        // 进入登录界面
        [appDelegate initLoginViewAsRootViewController];
        [VEUtility Logout];
        [appDelegate doCheckNewVersion];
    }
}

// 重导日志文件
+ (void)redirectNSLogToLogsFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError  *error = nil;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Logs"];
    BOOL result = [fileManager createDirectoryAtPath:logsFolderPath
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
    if (result == NO) return;
    
    NSArray *dirArray = [fileManager contentsOfDirectoryAtPath:logsFolderPath error:&error];
    if ([dirArray count] >= 7)
    {
        NSInteger difference = [dirArray count] - 7;
        NSArray *sortedArray = [dirArray sortedArrayUsingSelector:@selector(compare:)];  // 升序排列
        for (NSInteger i = 0; i <= difference; ++i)
        {
            [fileManager removeItemAtPath:[logsFolderPath stringByAppendingPathComponent:[sortedArray objectAtIndex:i]]
                                    error:&error];
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd"];
    NSString *stringDate = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logsFolderPath stringByAppendingPathComponent:stringDate];
    logFilePath = [logFilePath stringByAppendingPathExtension:@"txt"];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    NSLog(@"===================== Start =====================");
}

// 初始化ToolBar的背景颜色
+ (void)initBackgroudImageOfToolBar:(UIToolbar *)toolBar
{
    UIImage *toolBarIMG = [QCZipImageTool imageNamed:kToolBarBackgroundImage];
    [toolBar setBackgroundImage:toolBarIMG forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

// 将时间类型数据转换为字符串
+ (NSString *)timeIntervalToString:(NSTimeInterval)timeInterval
{
    NSNumber *numTimeInterval = [NSNumber numberWithLongLong:timeInterval];
    return [numTimeInterval stringValue];
}

+ (NSData *)compressImage:(UIImage *)orginalImage withMaxSize:(NSUInteger)maxSize
{
    NSData *orignalImageData = UIImageJPEGRepresentation(orginalImage, 1.0);
    NSUInteger orignalImageSize = [orignalImageData length];
    
    NSLog(@"---- orignalImageSize: %lu ----", (unsigned long)orignalImageSize);
    
    if (orignalImageSize > maxSize)
    {
        CGFloat i = 0.9;
        if (orignalImageSize >= k10MImageDataSize)
        {
            i = 0.0005;
        }
        else if (orignalImageSize >= k8MImageDataSize)
        {
            i = 0.005;
        }
        else if (orignalImageSize >= k4MImageDataSize)
        {
            i = 0.06;
        }
        else if (orignalImageSize >= k3MImageDataSize)
        {
            i = 0.20;
        }
        else if (orignalImageSize >= k2MImageDataSize)
        {
            i = 0.35;
        }
        else if (orignalImageSize >= k1MImageDataSize)
        {
            i = 0.65;
        }
        NSLog(@"beginning compress at radix: %f", i);
        
        CGFloat step = 0.15;
        for (; i > 0; (i -= step))
        {
            NSData *imageCompressedData = UIImageJPEGRepresentation(orginalImage, i);
            
            if ((imageCompressedData.length <= maxSize) || (i - step) <= 0.00001)
            {
                NSLog(@"compress image to size: %lu, at radix: %f", (unsigned long)imageCompressedData.length, i);
                
                return imageCompressedData;
            }
            else
            {
                @autoreleasepool {
                    imageCompressedData = nil;
                }
            }
        }
    }
    
    return orignalImageData;
}

// MD5加密
+ (NSString *)md5:(NSString *)stringToEncode
{
    if ([stringToEncode length])
    {
        const char *cStr = [stringToEncode UTF8String];
        unsigned char result[16] = {0};
        CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
        return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]];
    }
    return @"";
}


// 清理过期的历史缓存数据

+ (void)clearOverdueDataAtPersistentStore
{
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // 清理当前时刻起，15天之前的数据
    NSDate *overdueDate = [[NSDate date] dateByAddingTimeInterval:(-86400 *15)];
    NSTimeInterval overdueUTCTimeInterval = ([overdueDate timeIntervalSince1970] * 1000);
    
    // 清理Warn Entity
    NSEntityDescription *entityDescr = [NSEntityDescription entityForName:@"Warn"
                                                   inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescr];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(firstTimeRead <= %f)", overdueUTCTimeInterval];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *overdueObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (overdueObjects != nil && overdueObjects.count > 0)
    {
        for (NSManagedObject *object in overdueObjects)
        {
            [context deleteObject:object];
        }
        [context save:&error];
    }
    //NSLog(@"--- clear Warn data: %d", overdueObjects.count);
    
    // 清理RecommendRead Entity
    entityDescr = [NSEntityDescription entityForName:@"RecommendRead"
                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:predicate];
    
    error = nil;
    overdueObjects = nil;
    overdueObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (overdueObjects != nil && overdueObjects.count > 0)
    {
        for (NSManagedObject *object in overdueObjects)
        {
            [context deleteObject:object];
        }
        [context save:&error];
    }
    //NSLog(@"--- clear RecommendRead data: %d", overdueObjects.count);
    
    // 清理Intelligence Entity
    entityDescr = [NSEntityDescription entityForName:@"Intelligence"
                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entityDescr];
    [fetchRequest setPredicate:predicate];
    
    error = nil;
    overdueObjects = nil;
    overdueObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (overdueObjects != nil && overdueObjects.count > 0)
    {
        for (NSManagedObject *object in overdueObjects)
        {
            [context deleteObject:object];
        }
        [context save:&error];
    }
    //NSLog(@"--- clear Intelligence data: %d", overdueObjects.count);
}

+ (UIViewController *)topOfModalViewControllerStack:(UIViewController *)vc
{
    if (vc.presentedViewController == nil)
    {
        return vc;
    }
    else
    {
        return [VEUtility topOfModalViewControllerStack:vc.presentedViewController];
    }
}

// 锁屏

+ (void)lockScreen:(RESideMenu *)deckVC
{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 4.9f)
    {
        UIViewController *secondVC = nil;
        
        if (deckVC.presentedViewController == nil)
        {
            secondVC = deckVC;
        }
        else
        {
            UIViewController *topModalVC = [VEUtility topOfModalViewControllerStack:deckVC];
            if (![topModalVC isKindOfClass:[QCDeviceViewController class]])
            {
                secondVC = topModalVC;
            }
        }
        
        if (secondVC)
        {
//            if ([VEUtility isDeviceLockActivated]) {
                QCDeviceViewController *lockViewControlller = [[QCDeviceViewController alloc] initWithNibName:@"QCDeviceViewController" bundle:nil];
                lockViewControlller.action = VEPatternLockActionVerify;  // 验证设备锁
                [secondVC presentViewController:lockViewControlller animated:YES completion:NULL];
//            }
        }
    }
    else
    {
        UINavigationController *nav = (UINavigationController *)deckVC.contentViewController;
        UIViewController *topVC = nav.topViewController;
        
        if ([topVC isKindOfClass:[QCDeviceViewController class]])
        {
            if (((QCDeviceViewController *)topVC).action == VEPatternLockActionVerify)
            {
                return;
            }
        }
        
        QCDeviceViewController *lockViewControlller = [[QCDeviceViewController alloc] initWithNibName:@"QCDeviceViewController" bundle:nil];
        lockViewControlller.action = VEPatternLockActionVerify;  // 验证设备锁
        
        [nav pushViewController:lockViewControlller animated:YES];
    }
}

// 清理设备锁信息
+ (void)clearUpDeviceLock
{
    [VEUtility setPatternLockActivated:NO];
    [VEUtility setPatternLockPassword:@""];
    [VEUtility setPatternLockTime:0];
}

+ (void)setLockErrorTimes:(NSInteger)errorTimes
{
    if (errorTimes < 0)
    {
        errorTimes = 0;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockErrorTimes];
    [defaults setInteger:errorTimes forKey:key];
    [defaults synchronize];
}

+ (NSInteger)lockErrorTimes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockErrorTimes];
    return [defaults integerForKey:key];
}

+ (NSString *)currentPatternLockPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *passwordKey = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockPassword];
    return [defaults objectForKey:passwordKey];
}

+ (void)setPatternLockPassword:(NSString *)lockPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *passwordKey = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockPassword];
    [defaults setObject:lockPassword forKey:passwordKey];
    [defaults synchronize];
}

// 设备锁锁定时间
+ (NSInteger)currentPatternLockTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *lockTimeFey = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockTime];
    return [defaults integerForKey:lockTimeFey];
}

+ (void)setPatternLockTime:(NSInteger)lockTime
{
    lockTime = MAX(0, lockTime);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *lockTimeFey = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockTime];
    [defaults setInteger:lockTime forKey:lockTimeFey];
    [defaults synchronize];
}

// 设备锁是否激活
+ (BOOL)isDeviceLockActivated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *keyOpened = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockActivated];
    return [defaults boolForKey:keyOpened];
}

+ (void)setPatternLockActivated:(BOOL)isActivated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *keyOpened = [NSString stringWithFormat:@"%@_%@", [VEUtility currentUserName], kVEDeviceLockActivated];
    [defaults setBool:isActivated forKey:keyOpened];
    [defaults synchronize];
}

// 通知服务端累计数清零

+ (void)clearBadgeValueInServer
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[VEUtility sharedInstance] directSeverToClearBadgeValue];
    });
}

// 退出

+ (void)Logout
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[VEUtility sharedInstance] directSeverToLogout];
    });
}

+ (BOOL)isFailedToClearBadge
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@",  [VEUtility currentUserName], kFailedClearBadge];
    return [defaults boolForKey:key];
}

+ (void)setFailedToClearBadge:(BOOL)bFailed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@",  [VEUtility currentUserName], kFailedClearBadge];
    [defaults setBool:bFailed forKey:key];
    [defaults synchronize];
}

+ (void)changeCustomGroupIds:(NSString *)groupIds withSort:(NSString *)sort
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[VEUtility sharedInstance] directSeverToChangeCustomGroupIds:groupIds withSort:sort];
    });
}

- (void)directSeverToChangeCustomGroupIds:(NSString *)groupIds withSort:(NSString *)sort
{
    NSString *string = [NSString stringWithFormat:@"%@/ChangeSort", kBaseURL];
    NSURL *stringUrl = [NSURL URLWithString:string];
    
    NSString *paramStr = [NSString stringWithFormat:@"customGroupIds=%@&showOrders=%@", groupIds, sort];
    
    dispatch_async(synQueue, ^{
        
        // 同步请求
        FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
        NSData *receiveData = [httpRequestLoader startSynRequestWithURL:stringUrl
                                                             withParams:paramStr
                                                            withTimeOut:15];
        if (receiveData)
        {
            NSError *error = nil;
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&error];
            if (resultDic != nil && resultDic.count > 0)
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
                if ([jsonParser retrieveRusultValue] == 0)
                {
                    NSLog(@"--- change sort success. ---");
                }
            }
            
            if (error)
            {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        }
    });
}


- (void)directSeverToClearBadgeValue
{
    NSString *string = [NSString stringWithFormat:@"%@/clearBadge", kBaseURL];
    NSURL *stringUrl = [NSURL URLWithString:string];
    
    NSString *paramStr = [NSString stringWithFormat:@"uid=%ld", (long)currentUserID];
    
    dispatch_async(synQueue, ^{
        
        // 同步请求
        FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
        NSData *receiveData = [httpRequestLoader startSynRequestWithURL:stringUrl
                                                             withParams:paramStr
                                                            withTimeOut:15];
        if (receiveData)
        {
            NSError *error = nil;
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&error];
            if (resultDic != nil && resultDic.count > 0)
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
                if ([jsonParser retrieveRusultValue] == 0)
                {
                    [VEUtility setFailedToClearBadge:NO];
                    NSLog(@"--- clear badge success. ---");
                    
                    return ;
                }
            }
            
            if (error)
            {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        }
        
        [VEUtility setFailedToClearBadge:YES];
    });
}

- (void)directSeverToLogout
{
    NSString *string = [NSString stringWithFormat:@"%@/logout", kBaseURL];
    NSURL *stringUrl = [NSURL URLWithString:string];
    
    NSString *uuid = [VEUtility getUMSUDID];
    NSString *paramStr = [NSString stringWithFormat:@"deviceInfo=IOS-%@&user_unique=&happen_place=", uuid];
    
    dispatch_async(synQueue, ^{
        
        // 同步请求
        FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
        NSData *receiveData = [httpRequestLoader startSynRequestWithURL:stringUrl
                                                             withParams:paramStr
                                                            withTimeOut:15];
        if (receiveData)
        {
            NSError *error = nil;
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&error];
            
            if (resultDic != nil && resultDic.count > 0)
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
                if ([jsonParser retrieveRusultValue] == 0)
                {
                    NSLog(@"---- logout success -----");
                    return ;
                }
            }
        }
    });
}


/**
 * Creates a UUID to use as the temporary file name during the download
 */
+ (NSString *)createUUID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)
                      uuidStringRef];
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    return uuid;
}


+ (NSString *)currentUserName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserName];
}

+ (void)setCurrentUserName:(NSString *)userName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:kUserName];
    [defaults synchronize];
}

+ (NSString *)currentSkinVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:@"skinVersion"];
}

+ (void)setCurrentSkinVersion:(NSString *)version
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"skinVersion"];
    [defaults synchronize];
}

+ (NSString *)currentLocalVersion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:@"localVersion"];
}

+ (void)setCurrentLocalVersion:(NSString *)version{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"localVersion"];
    [defaults synchronize];
}


// 当前用户名
+ (NSString *)currentUserId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserId];
}

+ (void)setCurrentUserId:(NSString *)userId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:kUserId];
    [defaults synchronize];
}

+ (NSString *)isFirstLogin{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kFirstLogin];
}

+ (void)setIsFirstLogin:(NSString *)isFirstLogin{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:isFirstLogin forKey:kFirstLogin];
    [defaults synchronize];
}





// 服务器时间差
+ (NSString *)currentServiceTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserServiceTime];
}

+ (void)setCurrentServiceTime:(NSString *)time{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:time forKey:kUserServiceTime];
    [defaults synchronize];
}

//手机令牌Token
+ (NSString *)currentMobileToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserMobileToken];
}

+ (void)setCurrentMobileToken:(NSString *)token{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kUserMobileToken];
    [defaults synchronize];
}

//是否开启令牌
+ (NSString *)currentIsopenToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserOpenToken];
}

+ (void)setCurrentIsopenToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kUserOpenToken];
    [defaults synchronize];
}



+ (NSString *)currentUserPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:kUserPassword];
}

+ (void)setCurrentUserPassword:(NSString *)userPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userPassword forKey:kUserPassword];
    [defaults synchronize];
}

// APNS推送Token

+ (NSString *)currentAPNSToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *token = [defaults objectForKey:kAPNSToken];
    return (token.length > 0 ? token : @"0");
}

+ (void)setCurrentAPNSToken:(NSString *)token
{
    token = (token.length > 0 ? token : @"0");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kAPNSToken];
    [defaults synchronize];
}

+ (BOOL)shouldShowSortableTipView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", kVESortableTipView, [VEUtility currentUserName]];
    return ![defaults boolForKey:key];
}

+ (void)setShowSortableTipView:(BOOL)bShowAlert
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kVESortableTipView, [VEUtility currentUserName]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!bShowAlert forKey:key];
    [defaults synchronize];
}

+ (NSInteger)contentFontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSInteger fontSize = [defaults integerForKey:kVEContentViewFontSize];
    if (fontSize == 0)
    {
        fontSize = 18;
    }
    return fontSize;
}

+ (void)setContentFontSize:(NSInteger)fontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:fontSize forKey:kVEContentViewFontSize];
    [defaults synchronize];
}

//+ (double)newestTimeAtIntelligenceColumnType:(IntelligenceColumnType)columnType
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults synchronize];
//    
//    NSString *key = nil;
//    switch (columnType)
//    {
//        case IntelligenceColumnInstant:
//            key = @"Instant";
//            break;
//            
//        case IntelligenceColumnDaily:
//            key = @"Daily";
//            break;
//            
//        case IntelligenceColumnInternational:
//            key = @"International";
//            break;
//            
//        case IntelligenceColumnAllIntelligence:
//            key = @"AllIntelligence";
//            break;
//            
//        default:
//            key = @"";
//            break;
//    }
//    key = [key stringByAppendingFormat:@"_intelligence_%@", [VEUtility currentUserName]];
//    
//    return [defaults doubleForKey:key];
//}
//
//+ (void)setNewestTime:(double)newTimeReply atIntelligenceColumnType:(IntelligenceColumnType)columnType
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults synchronize];
//    
//    NSString *key = nil;
//    switch (columnType)
//    {
//        case IntelligenceColumnInstant:
//            key = @"Instant";
//            break;
//            
//        case IntelligenceColumnDaily:
//            key = @"Daily";
//            break;
//            
//        case IntelligenceColumnInternational:
//            key = @"International";
//            break;
//            
//        case IntelligenceColumnAllIntelligence:
//            key = @"AllIntelligence";
//            break;
//            
//        default:
//            key = @"";
//            break;
//    }
//    key = [key stringByAppendingFormat:@"_intelligence_%@", [VEUtility currentUserName]];
//    
//    [defaults setDouble:newTimeReply forKey:key];
//    [defaults synchronize];
//}

+ (BOOL)isOnRed
{
    return (g_IsMessageOnRed ||
            g_IsLatestAlertOnRed ||
            g_IsRecommendReadOnRed ||
            g_IsInternetAlertOnRed ||
            g_IsInformReviewOnRed);
}

+ (void)setToggleButton:(UIButton *)toggleBtn onRed:(BOOL)isRed
{
    NSString *imageName = nil;
    if (isRed)
    {
        imageName = @"ico-list-red";
    }
    else
    {
        imageName = @"ico-list";
    }
    [toggleBtn setImage:[QCZipImageTool imageNamed:imageName] forState:UIControlStateNormal];
}

+ (void)postNewFlagChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewFlagChangedNotification object:nil];
}

+ (void)postNewDayHappenedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDayHappenedNotification object:nil];
}

+ (NSString *)formatDateWithTimeInterval:(NSTimeInterval)timeInterval
{
    /*
     时间格式：
     1小时内用，多少分钟前；
     超过1小时，显示时间而无日期；
     超过24小时再显示日期；
     超过1年再显示年。
     */
    
    NSString *stringTime = nil;
    NSDate *today = [NSDate date];
    NSTimeInterval todayTimeInterval = [today timeIntervalSince1970];
    NSTimeInterval diff = (todayTimeInterval - timeInterval);
    
    NSDate *newReplyDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (0 < diff && diff <= 3600) // 1小时内
    {
        NSInteger minute = (diff / 60);
        if (minute == 0)
        {
            stringTime = @"现在";
        }
        else
        {
            stringTime = [NSString stringWithFormat:@"%ld分钟前", (long)minute];
        }
    }
    else if (diff <=  86400)  // 24小时内
    {
        [dateFormatter setDateFormat:@"MM-dd"];
        NSString *nowYMD = [dateFormatter stringFromDate:today];
        NSString *newReplyYMD = [dateFormatter stringFromDate:newReplyDate];
        
        if ([nowYMD isEqualToString:newReplyYMD])
        {
            [dateFormatter setDateFormat:@"HH:mm"];
            stringTime = [dateFormatter stringFromDate:newReplyDate];
        }
        else
        {
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            stringTime = [dateFormatter stringFromDate:newReplyDate];
        }
    }
    else if (diff <= (365 * 86400))  // 1年内
    {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        stringTime = [dateFormatter stringFromDate:newReplyDate];
    }
    else  // 大于1年
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        stringTime = [dateFormatter stringFromDate:newReplyDate];
    }
    
    return stringTime;
}

+ (NSString *)getUMSUDID
{
    NSString *udidInKeyChain = [STKeychain getPasswordForUsername:kUMSAgentUDID
                                                   andServiceName:kUMSAgent
                                                            error:nil];
    if (udidInKeyChain.length > 0)
    {
        return udidInKeyChain;
    }
    else
    {
        NSString *udid = nil;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            udid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        else
        {
            udid = [OpenUDID value];
        }
        
        if (udid.length > 0)
        {
            [STKeychain storeUsername:kUMSAgentUDID
                          andPassword:udid
                       forServiceName:kUMSAgent
                       updateExisting:NO
                                error:nil];
        }
        return udid;
    }
}

///////////////////////////////////////////////////////


//+ (UITableViewCell *)tableView:(UITableView *)tableView
//     cellForRecommendReadAgent:(RecommendAgent *)recommendAgent
//    cellSelectedBackgroundView:(UIView *)seledBackground;
//{
//    NSString *cellIdentifier = KIdentifier_RecommendReadNoPics;
//    NSInteger index = VERecommendReadTableViewCellNoPicsIndex;
//    
//    if (recommendAgent.thumbImageUrl.length > 0)
//    {
//        index = VERecommendReadTableViewCellHasPicsIndex;
//        cellIdentifier = KIdentifier_RecommendReadHasPics;
//    }
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:KNibName_RecommendColumn owner:self options:nil];
//        cell = [cellNib objectAtIndex:index];
//        cell.selectedBackgroundView = seledBackground;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    }
//    
//    VERecommendColumnTableViewCell *recommendCell = (VERecommendColumnTableViewCell *)cell;
//    
//    UILabel *cellLableTitle = (UILabel *)[cell viewWithTag:kCellTitleTag];
//    UILabel *cellLableTime = (UILabel *)[cell viewWithTag:kCellTimePostTag];
//    cellLableTitle.text = recommendAgent.title;
//    cellLableTime.text  = recommendAgent.timePost;
//    
//    UIImageView *imageBackground = nil;
//    if (index == VERecommendReadTableViewCellHasPicsIndex)
//    {
//        recommendCell.labelHasPicsMain.text = recommendAgent.title;
//        recommendCell.labelHasPicsTime.text = recommendAgent.timePost;
//        imageBackground = recommendCell.imageHasPicsBackground;
//        
//        [recommendCell.imageThumb setImageWithURL:[NSURL URLWithString:recommendAgent.thumbImageUrl]
//                                 placeholderImage:[UIImage imageNamed:kDefaultThunmbPic]];
//    }
//    else
//    {
//        recommendCell.labelNoPicsMain.text = recommendAgent.title;
//        recommendCell.labelNoPicsTime.text = recommendAgent.timePost;
//        imageBackground = recommendCell.imageNoPicsBackground;
//    }
//    
//    // 已读、未读背景颜色
//    NSString *bkImageName = nil;
//    if (recommendAgent.isRead)
//    {
//        cellLableTitle.textColor = readFontColor;
//        bkImageName = kGrayBK;
//    }
//    else
//    {
//        cellLableTitle.textColor = unreadFontColor;
//        bkImageName = kWhiteBK;
//    }
//    imageBackground.image = [UIImage imageNamed:bkImageName];
//    
//    return cell;
//}

+ (UITableViewCell *)cellForShowMoreTableView:(UITableView *)tableView
                   cellSelectedBackgroundView:(UIView *)seledBackground
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_ShowMore];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_ShowMore owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
    }
    cell.selectedBackgroundView = seledBackground;
    
    return cell;
}

+ (UITableViewCell *)cellForShowNoResultTableView:(UITableView *)tableView
                                      fillMainTip:(NSString *)mainTip
                                    fillDetailTip:(NSString *)detailTip
                                  backgroundColor:(UIColor *)backgroundColor;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_ShowNoResult];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_ShowNoResult owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
    }
    DLog(@"%p",cell);
    
    cell.contentView.backgroundColor = backgroundColor;
    ((VEShowNoResultsTableViewCell *)cell).labelMainTip.text = mainTip;
    ((VEShowNoResultsTableViewCell *)cell).labelDetailTip.text = detailTip;
    cell.contentView.backgroundColor = backgroundColor;
    
    return cell;
}

+ (UIView *)cellSelectedBackgroundView
{
    UIView *cellSelectedBackgroundView = [[UIView alloc] init];
    cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
    [cellSelectedBackgroundView sizeToFit];
    return cellSelectedBackgroundView;
}

@end


