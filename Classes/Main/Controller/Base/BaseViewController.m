//
//  BaseViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/1.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "BaseViewController.h"
#import "HttpClient.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

-(User *)user
{
    if (!_user) {
        User *user = [UserTool user];
        self.user = user;
    }
    return _user;
}

-(NSDictionary *)config
{
    if (!_config) {
        self.config = [QCZipImageTool getDictionaryWithName:kConfig];
    }
    return _config;
}

-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadImage) name:RELOADIMAGE object:nil];
}

- (void)reloadImage
{
    self.config = [QCZipImageTool getDictionaryWithName:kConfig];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:self.config[MainColor]]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOADIMAGE object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[HttpClient shareClient].operationQueue cancelAllOperations];
}

@end
