//
//  VESearchAlertTableViewCell.h
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kClearAllName @"清除搜索记录"

static NSString * const KIdentifier_SearchHistory    = @"CellSearchHistory";
static NSString * const kNibName_SearchAlert         = @"VESearchAlertTableViewCell";

@interface VESearchAlertTableViewCell : UITableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,copy) NSString *title;

@end
