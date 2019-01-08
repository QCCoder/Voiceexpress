//
//  VECustomAlertTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTool.h"
static NSString * const kNibName_CustomAlert     = @"VECustomAlertTableViewCell";
static NSString * const KIdentifier_CustomAlert  = @"CellCustomAlert";

@interface VECustomAlertTableViewCell : UITableViewCell

@property(nonatomic,strong ) IntelligenceAgent *agent;

+(instancetype)cellWithTableView:(UITableView *)tableView;

@end
