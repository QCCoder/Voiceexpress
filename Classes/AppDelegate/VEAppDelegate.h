//
//  VEAppDelegate.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-11.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow                                  *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

@property (assign, nonatomic) BOOL   launchFromWarnRemoteNotification;
@property (assign, nonatomic) BOOL   launchFromRecommendReadRemoteNotification;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

- (void)initWindowRootViewController;

// 将登录VC做为RootVC
- (void)initLoginViewAsRootViewController;

- (UIViewController *)centerViewControllerAtIndex:(NSInteger)index;

- (void)doCheckNewVersion;

@end
