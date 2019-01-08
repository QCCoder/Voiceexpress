//
//  VENetWorkReportingTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkReportingAgent.h"
static NSString * const KIdentifier_NetWorkReport = @"VENetWorkReportingTableViewCell";

@interface VENetWorkReportingTableViewCell : UITableViewCell

@property (nonatomic,strong) NetworkReportingAgent *agent;
+ (UIView *)cellSelectedBackgroundView;
+(instancetype)cellWithTableView:(UITableView *)tableView;
@property (weak, nonatomic) IBOutlet UIView *customeView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@end
