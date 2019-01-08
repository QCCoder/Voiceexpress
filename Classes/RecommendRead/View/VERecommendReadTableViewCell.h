//
//  VERecommendReadTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendColumnAgent.h"

#define KIdentifier_RecommendRead @"VERecommendReadTableViewCell"

@interface VERecommendReadTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageTip;

@property (strong, nonatomic) IBOutlet UILabel     *labelMain;

@property (strong, nonatomic) IBOutlet UIImageView *imageNew;

@property (nonatomic,strong) RecommendColumnAgent *agent;

+(instancetype)cellWithTableView:(UITableView *)tableView;

//+ (UIView *)cellSelectedBackgroundView;

@end

