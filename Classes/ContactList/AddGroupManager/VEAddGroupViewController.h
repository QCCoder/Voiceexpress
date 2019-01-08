//
//  VEAddGroupViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEAddGroupViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *customGroupList;

@property (nonatomic,copy) void(^addGroupList)(NSMutableArray *customGroupList);

@end
