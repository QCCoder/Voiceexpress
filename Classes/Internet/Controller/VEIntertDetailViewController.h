//
//  VEIntertDetailViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-9-26.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger VEIntertDetailViewFromIntert   = 201;       // 来自[区县上报]
static const NSInteger VEIntertDetailViewFromNetwork  = 202;       // 来自[外部上报]

@interface VEIntertDetailViewController : BaseViewController

@property(nonatomic, assign) NSInteger comeFrom;
@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, strong) NSMutableArray *listDatas;
@property (nonatomic,copy) NSString *uuid;
@end
