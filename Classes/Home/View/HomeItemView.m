//
//  HomeItemView.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeItemView.h"
#import "HomeCircleItemView.h"
@interface HomeItemView()

@property (nonatomic,weak) UIView *topView;
@property (nonatomic,weak) HomeCircleItemView *circleView;
@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,weak) UILabel *numberLabel;

@end

@implementation HomeItemView

-(void)awakeFromNib{
    [self setup];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setup{
    UIView *top =[[UIView alloc]initWithFrame:CGRectMake(0, 21, 0, 15)];
    top.backgroundColor = [UIColor clearColor];
    [self addSubview:top];
    _topView = top;
    
    HomeCircleItemView *circle = [[HomeCircleItemView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [top addSubview:circle];
    _circleView = circle;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    [top addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 27)];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberLabel];
    _numberLabel = numberLabel;
}

-(void)setCircle:(Circle *)circle{
    _circle = circle;

    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@未读",circle.numberOfNoRead]];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23.0] range:NSMakeRange(0, circle.numberOfNoRead.length)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11.0] range:NSMakeRange(circle.numberOfNoRead.length, 2)];
    _numberLabel.attributedText = attributeStr;

    _titleLabel.text = circle.subTitle;
    _circleView.type = self.tag;
    _circleView.circle = circle;
    
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat margin = 7;
    if (Main_Screen_Height < 568.0) {
        _topView.ve_y = 10;
        margin = 3;
    }
    
    _titleLabel.ve_width = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}].width;
    _titleLabel.ve_centerY = _circleView.ve_centerY;
    _titleLabel.ve_x = 14;
    _topView.ve_width = CGRectGetMaxX(_titleLabel.frame);
    _topView.ve_centerX = self.ve_width * 0.5;

    _numberLabel.ve_width = self.ve_width;
    _numberLabel.ve_y = CGRectGetMaxY(_topView.frame)+ margin;
    
    if (Main_Screen_Height < 568.0) {
        DLog(@"%lf",CGRectGetMaxY(_numberLabel.frame));
        self.ve_height = CGRectGetMaxY(_numberLabel.frame) + 2;
    }
}






@end
