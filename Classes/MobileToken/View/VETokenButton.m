//
//  VETokenButton.m
//  voiceexpress
//
//  Created by 钱城 on 15/11/3.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VETokenButton.h"
#import "UIView+Extension.h"

//颜色（RGB）
#define RGBCOLOR(r,g,b)          [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]



@implementation VETokenButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:43.0]];
        [self setBackgroundColor:RGBCOLOR(50, 50, 50)];
//        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:40.0]];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.bounds;
}


@end
