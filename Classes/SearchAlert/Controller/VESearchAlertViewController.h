//
//  VESearchAlertViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VESearchResultsViewController.h"

@interface VESearchAlertViewController : BaseViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate>

- (void)veResignFirstResponer;
@property (assign, nonatomic) SearchType searchType;

@end
