//
//  HomeCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeCell.h"

@interface HomeCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (nonatomic, strong)CAShapeLayer *outlineLayer;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;

@end

@implementation HomeCell

-(void)setHomeList:(HomeList *)homeList{
    _homeList = homeList;
    UIImage *image = [UIImage imageNamed:homeList.icon];
    self.iconView.image = image;
    self.titleLabel.text = homeList.title;
    
    self.subTitleLabel.text = homeList.newsTitle;

    if (self.homeList.hasNew) {
        self.newsImageView.hidden = NO;
    }else{
        self.newsImageView.hidden = YES;
    }
    
}

@end
