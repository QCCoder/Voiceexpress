//
//  CircleSubTitleLabel.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "CircleSubTitleLabel.h"

@interface CircleSubTitleLabel()

@property (nonatomic,strong) UILabel *numberLabel;

@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation CircleSubTitleLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel = [[UILabel alloc]init];
    
    _titleLabel.textColor = RGBCOLOR(149, 189, 201);
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:11.0];
    [self addSubview:_titleLabel];
    
    _numberLabel = [[UILabel alloc]init];
    _numberLabel.textColor = RGBCOLOR(149, 189, 201);
    _numberLabel.textAlignment = NSTextAlignmentLeft;
    _numberLabel.font = [UIFont systemFontOfSize:11.0];
    [self addSubview:_numberLabel];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
    [self setNeedsLayout];
}

-(void)setNumber:(NSString *)number{
    _number = number;
    _numberLabel.text = number;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _numberLabel.ve_width = 40;
    _numberLabel.ve_height = self.ve_height;
    _numberLabel.ve_y = 0;
    _numberLabel.ve_x = 0;
    
    _titleLabel.ve_width = self.ve_width - CGRectGetMaxX(_numberLabel.frame);
    _titleLabel.ve_height = self.ve_height;
    _titleLabel.ve_y = 0;
    _titleLabel.ve_x = CGRectGetMaxX(_numberLabel.frame);
    
    
}

@end
