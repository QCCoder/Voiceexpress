//
//  VECustomGroupDetailViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupTool.h"
@interface VECustomGroupDetailViewController : UIViewController

@property (nonatomic, strong) Group *singleGroupAgent;

@property (nonatomic,copy) void(^addGroupList)(Group *singleGroupAgent);

@end
