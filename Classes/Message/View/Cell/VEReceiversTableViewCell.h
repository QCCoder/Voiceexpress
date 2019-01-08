//
//  VEReceiversTableViewCell.h
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Receiver.h"


static NSString * const KNibName_Receivers    = @"VEReceiversTableViewCell";

@interface VEReceiversTableViewCell : UITableViewCell

+(instancetype)cellWithTable:(UITableView *)tableView;

@property (nonatomic,strong) NSArray *receivers;

@end
