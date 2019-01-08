//
//  VERecommendColumnViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-25.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//  二级列表页

#import <UIKit/UIKit.h>

@interface VERecommendColumnViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSString *columnID;

@property (copy, nonatomic) NSString *columnTitle;

@end
