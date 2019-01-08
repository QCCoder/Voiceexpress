//
//  VERecommendColumnTableViewCell.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendAgent.h"

static NSString * const KIdentifier_RecommendReadNoPics  = @"CellRecommendNoPicture";
static NSString * const KIdentifier_RecommendReadHasPics = @"CellRecommendHasPicture";

static NSString * const KNibName_RecommendColumn    = @"VERecommendColumnTableViewCell";

static const NSInteger VERecommendReadTableViewCellNoPicsIndex        = 0;
static const NSInteger VERecommendReadTableViewCellHasPicsIndex       = 1;

@interface VERecommendColumnTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel     *labelHasPicsMain;
@property (strong, nonatomic) IBOutlet UILabel     *labelHasPicsTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageThumb;
@property (strong, nonatomic) IBOutlet UIImageView *imageHasPicsBackground;

@property (strong, nonatomic) IBOutlet UILabel     *labelNoPicsMain;
@property (strong, nonatomic) IBOutlet UILabel     *labelNoPicsTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageNoPicsBackground;

@property (nonatomic,strong) RecommendAgent *agent;
+ cellWithTableView:(UITableView*)tableView agent:(RecommendAgent *)agent;
@end
