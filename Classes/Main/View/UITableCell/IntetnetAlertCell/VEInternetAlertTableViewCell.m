//
//  VEInternetAlertTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEInternetAlertTableViewCell.h"

@implementation VEInternetAlertTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    UIImageView *cellBKImage = (UIImageView *)[self viewWithTag:kCellImgBKTag];
    
    if (highlighted) {
        cellBKImage.image = [UIImage imageNamed:@"bar-listbg-old.png"];
    }else{
        cellBKImage.image = [UIImage imageNamed:@"bar-listbg-new.png"];
    }
}

@end
