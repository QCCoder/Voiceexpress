//
//  VEMainRightDetailTableViewCell.m
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEMainRightDetailTableViewCell.h"

@interface VEMainRightDetailTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bkView;

@end

@implementation VEMainRightDetailTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:YES];
    
    if (highlighted) {
        self.bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        self.bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-new.png"];
    }
}

@end
