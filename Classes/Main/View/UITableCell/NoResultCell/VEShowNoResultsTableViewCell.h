//
//  VEShowNoResultsTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString * const kNibName_ShowNoResult    = @"VEShowNoResultsTableViewCell";
static NSString * const KIdentifier_ShowNoResult = @"CellNoResults";

@interface VEShowNoResultsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelMainTip;
@property (strong, nonatomic) IBOutlet UILabel *labelDetailTip;

@end
