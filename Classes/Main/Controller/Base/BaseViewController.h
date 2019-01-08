//
//  BaseViewController.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/1.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserTool.h"
@interface BaseViewController : UIViewController

@property (nonatomic,strong) User *user;

@property (nonatomic,strong) NSDictionary *config;

- (void)reloadImage;
-(void)addObserver;
@end
