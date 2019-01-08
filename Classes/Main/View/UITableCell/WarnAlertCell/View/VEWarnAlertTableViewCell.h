//
//  VEWarnAlertTableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const KIdentifier_WarnAlert = @"CellWarnAlert";
static NSString * const KNibName_WarnAlert    = @"VEWarnAlertTableViewCell";

@interface VEWarnAlertTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelArea;
@property (strong, nonatomic) IBOutlet UILabel *labelSiteName;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageLevel;
@property (strong, nonatomic) IBOutlet UIImageView *imageBackground;

@end
