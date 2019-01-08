//
//  VESearchAlertTableViewCell.m
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VESearchAlertTableViewCell.h"

@interface VESearchAlertTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bkView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation VESearchAlertTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    VESearchAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_SearchHistory];
    if (cell == nil){
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_SearchAlert owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
    if ([title isEqualToString:kClearAllName]) {
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = RGBCOLOR(180, 179, 180);;
        _bkView.image = [QCZipImageTool imageNamed:@"reply_box.png"];
    }else{
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = unreadFontColor;
        _bkView.image = [QCZipImageTool imageNamed:@"reply_box.png"];
    }
}
@end
