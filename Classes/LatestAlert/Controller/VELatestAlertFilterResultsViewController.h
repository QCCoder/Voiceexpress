//
//  VELatestAlertFilterResultsViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-20.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VELatestAlertFilterResultsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (copy, nonatomic) NSString *filterWarnLevel;
@end
