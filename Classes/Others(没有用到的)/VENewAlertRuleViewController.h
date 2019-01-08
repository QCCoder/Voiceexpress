//
//  VENewAlertRuleViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger VENewAlertRuleViewDeleteAlertRuleAlertViewTag = 200;
static const NSInteger VENewAlertRuleViewChangeAlertRuleAction       = 411;

@interface VENewAlertRuleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (assign, nonatomic) NSInteger fromAction;
@property (copy, nonatomic) NSString *titleName;
@property (strong, nonatomic) NSMutableDictionary *newAlertRuleDic;
@end
