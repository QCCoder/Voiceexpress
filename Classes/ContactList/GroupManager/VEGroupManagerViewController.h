//
//  VEGroupManagerViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-18.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEGroupManagerViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *customGroupList;

@property (nonatomic,copy) void(^getCustomGropList)(NSMutableArray *customGroupList);

@end
