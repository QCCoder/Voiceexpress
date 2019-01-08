//
//  VEShowMoreTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kNibName_ShowMore     = @"VEShowMoreTableViewCell";
static NSString * const KIdentifier_ShowMore  = @"CellShowMore";

@interface VEShowMoreTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelMain;

@end
