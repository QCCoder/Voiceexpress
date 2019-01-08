//
//  VEFilterLevelTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kNibName_FilterLevel     = @"VEFilterLevelTableViewCell";
static NSString * const KIdentifier_FilterLevel  = @"CellFilterLevel";

@interface VEFilterLevelTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageLevel;
@property (strong, nonatomic) IBOutlet UILabel     *labelMain;

@end
