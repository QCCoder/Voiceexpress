//
//  VENewAlertRuleDetailViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VENewAlertRuleDetailViewController : UIViewController
@property (copy, nonatomic) NSString *titleName;
@property (unsafe_unretained, nonatomic) NSMutableDictionary *alertRuleDic;
@property (assign, nonatomic) NSInteger fromRow;
@end
