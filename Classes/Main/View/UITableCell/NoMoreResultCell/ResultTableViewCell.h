//
//  ResultTableViewCell.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/24.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultTableViewCell : UITableViewCell

+(id)cellWithTableView:(UITableView *)tableView isNoMoreResult:(BOOL)isNoMoreResult;

@end
