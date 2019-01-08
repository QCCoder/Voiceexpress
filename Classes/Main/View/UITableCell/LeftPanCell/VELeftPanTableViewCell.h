//
//  VELeftPanTableViewCell.h
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kNibName_LeftPan     = @"VELeftPanTableViewCell";
static NSString * const KIdentifier_LeftPan  = @"CellLeftPan";

@interface VELeftPanTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelMain;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewLog;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewNew;

@end
