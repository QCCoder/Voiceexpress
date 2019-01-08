//
//  VEIntertDetailController.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "BaseViewController.h"
#import "VEInternetTool.h"

#define VEIntertDetailViewFromIntert 201       // 来自[区县上报]
#define VEIntertDetailViewFromNetwork 202       // 来自[外部上报]

@interface VEIntertDetailController : BaseViewController

@property (nonatomic,strong) Agent *agent;

@property (nonatomic,assign) NSInteger comeFrom;

@end
