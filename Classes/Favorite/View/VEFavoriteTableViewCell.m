//
//  VEFavoriteTableViewCell.m
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEFavoriteTableViewCell.h"

@interface VEFavoriteTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bkView;


@end

@implementation VEFavoriteTableViewCell

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        _bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-new.png"];
    }
}

@end
