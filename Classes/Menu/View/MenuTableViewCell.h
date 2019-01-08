//
//  MenuTableViewCell.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic)  UIView *line;

@property (nonatomic,strong) Menu *menu;

@property (weak, nonatomic) UIImageView *imageNew;

+(id)cellWithTableView:(UITableView *)tableView;

@end
