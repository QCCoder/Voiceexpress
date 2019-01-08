//
//  DockItem.m
//  GonganNew
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCDockItem.h"

@interface QCDockItem()

@property (nonatomic,weak) UIView *line;

@end

@implementation QCDockItem

-(UIImageView *)boxImageView
{
    if (!_boxImageView) {
        UIImageView *name = [[UIImageView alloc]initWithImage:[QCZipImageTool imageNamed:Config(Menu_Icon_Red_Point)]];
        [self addSubview:name];
        self.boxImageView = name;
    }
    return _boxImageView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self setAdjustsImageWhenHighlighted:NO];
        UIView *line = [[UIView alloc]init];
        [line setBackgroundColor:RGBCOLOR(228, 228, 229)];
        [self addSubview:line];
        _line = line;
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    //分割线位置
    CGSize size = self.frame.size;
    CGFloat H = 15;
    CGFloat Y = size.height * 0.5 - H * 0.5;
    [_line setFrame:CGRectMake(size.width, Y, 2, H)];
    
    //文字位置
    CGRect titleFrame = self.titleLabel.frame;
    CGFloat titleWidth =[self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    titleFrame.origin.x = (size.width - titleWidth) * 0.5;
    titleFrame.origin.y = (size.height - titleFrame.size.height) * 0.5;
    [self.titleLabel setFrame:titleFrame];

    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = CGRectGetMaxY(self.titleLabel.frame) + 5;
    imageFrame.origin.y = 6;
    [self.imageView setFrame:imageFrame];
    self.boxImageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 4, 6, 11, 11);
}

@end
