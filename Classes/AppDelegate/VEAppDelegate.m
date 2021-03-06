//
//  VEAppDelegate.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-11.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAppDelegate.h"
#import "VELoginViewController.h"
#import "VELatestAlertViewController.h"
#import "VEFavoriteViewController.h"
#import "VESearchAlertViewController.h"
#import "VEMoreSettingViewController.h"
#import "VERecommendReadViewController.h"
#import "VEMessageViewController.h"
#import "VEInternetViewController.h"
#import "VEChangePassWordViewController.h"
#import "VEInformationReviewViewController.h"
#import "RESideMenu.h"
#import "VEVLeftViewController.h"
#import "VEMobileTokenViewController.h"
#import "LoginTool.h"
#import "VEOriginalViewController.h"
#import "ThemeTool.h"
#import "QCDeviceViewController.h"
#import "HomeViewController.h"
extern NSString  *kAppVersion;
extern BOOL      isTopLeader;
extern BOOL      isDefaultPassword;
extern BOOL      isSecurityCtrlOpen;
extern BOOL      isLockCtrlOpen;
extern BOOL      networkReportReview;

BOOL g_IsMessageOnRed       = NO;  // 情报交互
BOOL g_IsLatestAlertOnRed   = NO;  // 舆情预警
BOOL g_IsRecommendReadOnRed = NO;  // 推荐阅读
BOOL g_IsInternetAlertOnRed = NO;  // 信息上报
BOOL g_IsInformReviewOnRed  = NO;  // 信息审核

static const NSUInteger kCheckVersionInterval = 86400;              // 1天

@interface VEAppDelegate () <UIAlertViewDelegate, RESideMenuDelegate>

@property (assign, nonatomic) BOOL      registerApnsDone;
@property (strong, nonatomic) NSDate    *launchedTime;
@property (strong, nonatomic) NSDate    *enterBackgroundTime;
@property (strong, nonatomic) NSDate    *enterForegroundTime;

@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel          *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@property (strong, nonatomic) UIViewController *messageVC;
@property (strong, nonatomic) UIViewController *internetVC;
@property (strong, nonatomic) UIViewController *latestAlertVC;
@property (strong, nonatomic) UIViewController *recommendReadVC;
@property (strong, nonatomic) UIViewController *searchAlertVC;
@property (strong, nonatomic) UIViewController *informationReviewVC;
@property (strong, nonatomic) UIViewController *favoriteVC;
@property (strong, nonatomic) UIViewController *settingVC;
@property (strong, nonatomic) UIViewController *homeVC;
@property (nonatomic,strong) UIViewController *mobileTokenVC;

@end

@implementation VEAppDelegate

@synthesize managedObjectContext        = _managedObjectContext;
@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // 注：以下方法的调用顺序不要修改
    [self setUp];
    [ThemeTool loadTheme];
    [self application:application dealWithLaunchOptions:launchOptions];
    [self doCheckNewVersion];
    
    // 如果开启了自动登录，则同步地登录
    if ([VEUtility shouldAutoLoginToServer] && [LoginTool synchronousLoginToServer])
    {
        [self initWindowRootViewController];
        [self lockScreenAtRightNow:YES];
    }else{
        [self initLoginViewAsRootViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    // 初始化第三方平台
    //[self initThirdPartyPlatform];
    
    return YES;
}

- (void)setUp
{
    self.registerApnsDone = NO;
    self.launchedTime = [[NSDate date] copy];
    kAppVersion = [VEUtility curAppVersion];
    
    // 重导日志输出文件
//    [VEUtility redirectNSLogToLogsFolder];
    
    DLog(@"--- launching ---");
    
    // 注册推送服务
    [self registerForAPNSUntilDone];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([self.window.rootViewController isKindOfClass:[RESideMenu class]]){
        self.enterBackgroundTime = [[NSDate date] copy];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"--- background -> forground. ---");
    if (self.window.rootViewController && [self.window.rootViewController isKindOfClass:[RESideMenu class]]){
        self.enterForegroundTime = [[NSDate date] copy];
        [self lockScreenAtRightNow:NO];
        if (application.applicationIconBadgeNumber){
            RESideMenu *deckVC = (RESideMenu *)self.window.rootViewController;
            [deckVC hideMenuViewController];
            [deckVC setContentViewController:self.messageVC];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:kAppChangeLeftPanSelIndexNotification
                                  object:nil
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:0], @"index", nil]];
        
            [VEUtility clearBadgeValueInServer];
        }else{
            if ([VEUtility isFailedToClearBadge]){
                [VEUtility clearBadgeValueInServer];
            }
        }
        [self cleanBadgeAndNotice:application];
    }
    
    // 如果程序启动之后一直在运行,当从后台进入到前台,则每隔一天检测版本更新
    // 重导日志、清理过期数据
    NSDate *nowTime = [NSDate date];
    NSTimeInterval difference = [nowTime timeIntervalSinceDate:self.launchedTime];
    if (difference > kCheckVersionInterval){
        self.launchedTime = [nowTime copy];
        [self doCheckNewVersion];
        [VEUtility redirectNSLogToLogsFolder];
        
        // 如果程序一直运行或后台，则每个一天重新刷新列表。（服务端会每天清理数据）
        [VEUtility postNewDayHappenedNotification];
        
        if (self.window.rootViewController && [self.window.rootViewController isKindOfClass:[RESideMenu class]]){
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [VEUtility clearOverdueDataAtPersistentStore];
            });
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil){
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]){
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - My Methods

- (UIViewController *)messageVC
{
    if (_messageVC == nil)
    {
        VEMessageViewController *messageController = [[VEMessageViewController alloc] initWithNibName:@"VEMessageViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:messageController];
        _messageVC = centerController;
    }
    return _messageVC;
}

- (UIViewController *)internetVC
{
    if (_internetVC == nil)
    {
        VEInternetViewController *internetController = [[VEInternetViewController alloc] initWithNibName:@"VEInternetViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:internetController];
        _internetVC = centerController;
    }
    return _internetVC;
}

- (UIViewController *)latestAlertVC
{
    if (_latestAlertVC == nil)
    {
        VELatestAlertViewController *latestAlertController = [[VELatestAlertViewController alloc] initWithNibName:@"VELatestAlertViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:latestAlertController];
        _latestAlertVC = centerController;
    }
    return _latestAlertVC;
}

- (UIViewController *)recommendReadVC
{
    if (_recommendReadVC == nil)
    {
        VERecommendReadViewController *recommendReadController = [[VERecommendReadViewController alloc] initWithNibName:@"VERecommendReadViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:recommendReadController];
        _recommendReadVC = centerController;
    }
    return _recommendReadVC;
}

- (UIViewController *)searchAlertVC
{
    if (_searchAlertVC == nil)
    {
        VESearchAlertViewController *searchAlertController = [[VESearchAlertViewController alloc] initWithNibName:@"VESearchAlertViewController" bundle:nil];
        searchAlertController.searchType = SearchTypeNormal;
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:searchAlertController];
        _searchAlertVC = centerController;
    }
    return _searchAlertVC;
}

- (UIViewController *)informationReviewVC
{
    if (_informationReviewVC == nil)
    {
        VEInformationReviewViewController *informReviwVC = [[VEInformationReviewViewController alloc] init];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:informReviwVC];
        _informationReviewVC = centerController;
    }
    return _informationReviewVC;
}

- (UIViewController *)favoriteVC
{
    if (_favoriteVC == nil)
    {
        VEFavoriteViewController *favoriteController = [[VEFavoriteViewController alloc]
                                                        initWithNibName:@"VEFavoriteViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:favoriteController];
        _favoriteVC = centerController;
    }
    return _favoriteVC;
}

- (UIViewController *)settingVC
{
    if (_settingVC == nil)
    {
        VEMoreSettingViewController *settingController = [[VEMoreSettingViewController alloc] initWithNibName:@"VEMoreSettingViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:settingController];
        _settingVC = centerController;
    }
    return _settingVC;
}

- (UIViewController *)homeVC
{
    if (_homeVC == nil)
    {
        HomeViewController *settingController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        VENavViewController *centerController = [[VENavViewController alloc] initWithRootViewController:settingController];
        _homeVC = centerController;
    }
    return _homeVC;
}

-(UIViewController *)mobileTokenVC
{
    if (!_mobileTokenVC) {
        VEMobileTokenViewController *class = [[VEMobileTokenViewController alloc]init];
        UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:class];
        centerController.navigationBar.hidden = NO;
        self.mobileTokenVC = centerController;
    }
    return _mobileTokenVC;
}

- (void)registerForAPNSUntilDone
{
    // 等待注册推送服务结束
    // 结束的条件:注册推送服务成功或失败了、计时时间耗完了
    
    [VEUtility registerForRemoteNotifications];
    
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self registerApnsTimeOutFired];
    });
    
    while(!self.registerApnsDone)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
}

// Deck VC

- (RESideMenu *)generateControllerStack
{
    UIViewController *centerVC = self.homeVC;
    if (!isTopLeader && self.launchFromWarnRemoteNotification)
    {
        centerVC = self.latestAlertVC;
    }
    else if (!isTopLeader && self.launchFromRecommendReadRemoteNotification)
    {
        centerVC = self.recommendReadVC;
    }
    
    VEVLeftViewController *leftController = [[VEVLeftViewController alloc]
                                             initWithNibName:@"VEVLeftViewController" bundle:nil];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc]initWithContentViewController:centerVC leftMenuViewController:leftController rightMenuViewController:nil];
    sideMenuViewController.contentViewShadowEnabled = NO;
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.scaleContentView = NO;
    sideMenuViewController.scaleBackgroundImageView = NO;
    sideMenuViewController.scaleMenuView = NO;
    sideMenuViewController.fadeMenuView = NO;
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewInPortraitOffsetCenterX = [UIScreen mainScreen].bounds.size.width / 4;

    return sideMenuViewController;
}

// 处理从通知栏打开推送通知，启动了程序

- (void)application:(UIApplication *)application dealWithLaunchOptions:(NSDictionary *)launchOptions
{
    self.launchFromWarnRemoteNotification = NO;
    self.launchFromRecommendReadRemoteNotification = NO;
    
    NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSString *notifyType = [userInfo objectForKey:@"notifyType"];
    if ([notifyType isEqualToString:@"warn"])
    {
        self.launchFromWarnRemoteNotification = YES;
    }
    else if ([notifyType isEqualToString:@"readingArticle"])
    {
        self.launchFromRecommendReadRemoteNotification = YES;
    }
    
    if (userInfo || application.applicationIconBadgeNumber > 0)
    {
        [VEUtility clearBadgeValueInServer];
    }
    
    // 清理图标右上角的数字
    [self cleanBadgeAndNotice:application];
}

// 清理图标右上角的数字

- (void)cleanBadgeAndNotice:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    NSArray* scheduledNotifications = [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;
}

// 切换Deck VC的主视图

- (UIViewController *)centerViewControllerAtIndex:(NSInteger)index
{
    UIViewController *centerVC = nil;
    if (isTopLeader)
    {
        switch (index)
        {
            case 0:
                centerVC = self.homeVC;
                
                break;
                
            case 1:
                centerVC = self.messageVC;
                
                    break;
                
            case 2:
                
                centerVC = (networkReportReview ? self.informationReviewVC : self.settingVC);
                break;
            case 3:
                centerVC = self.settingVC;
                break;
                
            case 10:
                centerVC = self.mobileTokenVC;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (index)
        {
            case 0:
                centerVC = self.homeVC;
                break;
            case 1:
                centerVC = self.messageVC;
                break;
                
                case 2:
                    centerVC = self.internetVC;
                    break;
    
                case 3:
                    centerVC = self.latestAlertVC;
                    break;
    
                case 4:
                    centerVC = self.recommendReadVC;
                    break;
    
                case 5:
                    centerVC = self.searchAlertVC;
                    break;
    
                case 6:
                    centerVC = (networkReportReview ? self.informationReviewVC : self.favoriteVC);
                    break;
    
                case 7:
                    centerVC = (networkReportReview ?self.favoriteVC : self.settingVC);
                    break;
                
                case 8:
                    centerVC = self.settingVC;
                    break;
                
                case 10:
                    centerVC = self.mobileTokenVC;
                    break;
                
            default:
                break;
        }
    }
    
    return centerVC;
}


// 初始化rootVC

- (void)initWindowRootViewController
{
    if (isSecurityCtrlOpen && isDefaultPassword)
    {
        // 如果是默认的密码，提示用户修改默认的密码
        [self showChangeDefaultPasswordInterface];
        return;
    }
    
    if ([UserTool user].isLockCtrlOpen && ![VEUtility isDeviceLockActivated])
    {
        // 如果设备锁未开启，提示用户绘制设备锁
        [self showInitDeviceLockInterface];
        return;
    }
    
    // 重要的，不要删除
    g_IsMessageOnRed       = NO;
    g_IsLatestAlertOnRed   = NO;
    g_IsRecommendReadOnRed = NO;
    g_IsInternetAlertOnRed = NO;
    g_IsInformReviewOnRed  = NO;
    
    if (_managedObjectContext)
    {
        [self saveContext];
        self.managedObjectContext = nil;
    }
    if (_persistentStoreCoordinator) { self.persistentStoreCoordinator = nil; }
    if (_managedObjectModel) { self.managedObjectModel = nil; }
    
    // Deck VC
    self.window.rootViewController = [self generateControllerStack];
    
    //isTopLeader = YES; // only for test
    if (!isTopLeader)
    {
        // 重要的，不要删除
        if (self.latestAlertVC)  { ; }      // 舆情预警
        if (self.internetVC)     { ; }      // 区县上报
        if (self.recommendReadVC){ ; }      // 推荐阅读
        if (self.informationReviewVC) { ; } // 信息审核
    }
}

- (void)initLoginViewAsRootViewController
{
    // 重要地的，不要删除
    if (_messageVC)         { self.messageVC       = nil; }
    if (_internetVC)        { self.internetVC      = nil; }
    if (_latestAlertVC)     { self.latestAlertVC   = nil; }
    if (_recommendReadVC)   { self.recommendReadVC = nil; }
    if (_searchAlertVC)     { self.searchAlertVC   = nil; }
    if (_favoriteVC)        { self.favoriteVC      = nil; }
    if (_settingVC)         { self.settingVC       = nil; }
    if (_informationReviewVC) { self.informationReviewVC = nil; }
    
    VELoginViewController *loginViewController = [[VELoginViewController alloc]
                                                  initWithNibName:@"VELoginViewController" bundle:nil];
    VENavViewController *nav = [[VENavViewController alloc] initWithRootViewController:loginViewController];
    
    nav.navigationBar.hidden = YES;
    
    self.window.rootViewController = nav;
}

- (void)showChangeDefaultPasswordInterface
{
    VEChangePassWordViewController *changePwdVC = [[VEChangePassWordViewController alloc] initWithNibName:@"VEChangePassWordViewController" bundle:nil];
    changePwdVC.action = OperationChangeDefaultPassword;
    
    self.window.rootViewController = changePwdVC;
}

- (void)showInitDeviceLockInterface
{
    
    QCDeviceViewController *lockViewControlller = [[QCDeviceViewController alloc] initWithNibName:@"QCDeviceViewController" bundle:nil];
    lockViewControlller.action = VEPatternLockActionLaunchInit;
    
    self.window.rootViewController = lockViewControlller;
}

- (void)registerApnsTimeOutFired
{
    self.registerApnsDone = YES;
}

// 判别是否需锁屏

- (void)lockScreenAtRightNow:(BOOL)rightNow
{
    if ([VEUtility isDeviceLockActivated])
    {
        if (rightNow)
        {
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self doLockScreen];
            });
        }
        else
        {
            NSInteger time = [VEUtility currentPatternLockTime];
            NSTimeInterval timeInterval = [self.enterForegroundTime timeIntervalSinceDate:self.enterBackgroundTime];
            if (timeInterval >= (time * 60))
            {
                [self doLockScreen];
            }
        }
    }
}

// 锁屏

- (void)doLockScreen
{
    if ([self.window.rootViewController isKindOfClass:[RESideMenu class]])
    {
        [VEUtility lockScreen:(RESideMenu *)self.window.rootViewController];
    }
}

// 检测是否有版本更新

- (void)doCheckNewVersion
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self checkNewVersionAction];
    });
}

- (void)checkNewVersionAction
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        
        NSDictionary *resultDic = [VEUtility checkNewVersion];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSInteger res = [[resultDic valueForKey:kHasNewVersion] integerValue];
            if (res == 10)
            {
                BOOL bMandatoryUpdate = [[resultDic valueForKey:kMandatoryUpdate] boolValue];
                NSString *updateDiscrip = nil;
                NSString *serverDiscrip = [resultDic valueForKey:kUpdateDiscription];
                if (serverDiscrip.length > 0)
                {
                    updateDiscrip = serverDiscrip;
                }
                else
                {
                    updateDiscrip = @"有最新版本了,请您下载最新版本。\n";
                }
                
                UIAlertView *alert = nil;
                if (bMandatoryUpdate)
                {
                    // 需要强制性更新
                    alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                       message:updateDiscrip
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"立刻更新", nil];
                }
                else
                {
                    // 非强制性更新
                    alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                       message:updateDiscrip
                                                      delegate:self
                                             cancelButtonTitle:@"请勿下载"
                                             otherButtonTitles:@"立刻更新", nil];
                }
                alert.tag = 10;
                [alert show];
            }
        }];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10)
    {
        NSString *butTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([butTitle isEqualToString:@"立刻更新"])
        {
            [VEUtility downLoadNewVersion];
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VoiceExpress" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }

    NSString *userName = [VEUtility currentUserName];
    userName = (userName.length > 0 ? userName : @"");

    NSString *storeFileName = [NSString stringWithFormat:@"VoiceExpress_%@.sqlite", userName];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeFileName];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
     NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error])
    {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Handling Remote Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *apnsToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                                       stringByReplacingOccurrencesOfString:@">" withString:@""]
                                                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    [VEUtility setCurrentAPNSToken:apnsToken];
    self.registerApnsDone = YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"Fail to register for remoteNotifications: %@.", [error localizedDescription]);
    self.registerApnsDone = YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState curAppState = [application applicationState];
    if (curAppState == UIApplicationStateActive)
    {
        // 如果程序处于前台运行，接收到的推送消息手机不会有提示。
        NSNumber *badge = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
        if (badge.integerValue > 0)
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:kAppDidReceiveRemoteNotification object:nil];
            [VEUtility clearBadgeValueInServer];
        }
        
    }
    else
    {
        // 如果程序处于后台或非活动状态，通过点击通知栏相应的通知时，跳转到相应通知的界面
        NSString *notifyType = [userInfo objectForKey:@"notifyType"];
        if ([self.window.rootViewController isKindOfClass:[RESideMenu class]])
        {
            NSInteger selIndex = 0;
            RESideMenu *deckVC = (RESideMenu *)self.window.rootViewController;
            
            if ([notifyType isEqualToString:@"warn"] && !isTopLeader)
            {
                selIndex = 2;
                deckVC.contentViewController = self.latestAlertVC;
            }
            else if ([notifyType isEqualToString:@"readingArticle"])
            {
                selIndex = 3;
                deckVC.contentViewController = self.recommendReadVC;
            }
            else
            {
                deckVC.contentViewController = self.messageVC;
            }
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:kAppChangeLeftPanSelIndexNotification
                                  object:nil
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:selIndex], @"index", nil]];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urlString = [url absoluteString];
    //进入详情页
    NSRange idRange = [urlString rangeOfString:@"voiceexpressgongan://"];
    if(idRange.location != NSNotFound) {
        NSString *originalUrl =[urlString substringFromIndex:idRange.length];
        NSArray *array = @[@"https",@"http",@"ftp",@"file"];
        BOOL isadd = false;
        for (NSString *str in array) {
            if ([self isKeyWord:originalUrl checkStr:str]) {
                originalUrl = [originalUrl stringByReplacingOccurrencesOfString:str withString:[NSString stringWithFormat:@"%@:",str]];
                isadd = true;
                break;
            }
        }
        
        if([originalUrl rangeOfString:@"https"].location == NSNotFound &&
           [originalUrl rangeOfString:@"http"].location == NSNotFound &&
           [originalUrl rangeOfString:@"ftp"].location == NSNotFound &&
           [originalUrl rangeOfString:@"file"].location == NSNotFound && !isadd){
            originalUrl = [NSString stringWithFormat:@"http://%@",originalUrl];
        }
        
        VEOriginalViewController *orgVC = [[VEOriginalViewController alloc]init];
        orgVC.originalUrl = originalUrl;
        UIViewController *vc = [self.window.rootViewController.childViewControllers[1].childViewControllers lastObject];
        [vc.navigationController pushViewController:orgVC animated:YES];
    }
    return YES;
}

-(BOOL)isKeyWord:(NSString *)url checkStr:(NSString *)checkStr{

    NSString *check1 = [url substringToIndex:checkStr.length];
    NSString *check2 = [url substringWithRange:NSMakeRange(checkStr.length, 1)];
    
    if ([check1 isEqualToString:checkStr]) {
        if (![check2 isEqualToString:@":"]) {
            return YES;
        }
    }
    return NO;
}

-(void)willPresentAlertView:(UIAlertView *)alertView{
    
    DLog(@"%@",alertView.subviews);
    for( UIView * view in alertView.subviews )
    {
        if( [view isKindOfClass:[UILabel class]] )
        {
            UILabel* label = (UILabel*) view;
            label.textAlignment = NSTextAlignmentLeft;
            
        }
    }
}

@end




