//
//  NormalHead.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "NormalHead.h"

@interface NormalHead()

@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,weak) UILabel *timeLabel;

@property (nonatomic,weak) UILabel *labelWarnningType;

@end

@implementation NormalHead



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, Main_Screen_Width - 10, [UIFont boldSystemFontOfSize:20.0].lineHeight * 2)];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor blackColor];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 22, Main_Screen_Width, 16)];
    timeLabel.font = [UIFont boldSystemFontOfSize:14.0];
    timeLabel.textColor = RGBCOLOR(185, 185, 185);
    [self addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    UILabel *labelWarnningType = [[UILabel alloc]initWithFrame:CGRectMake(5, 22, 0, 16)];
    labelWarnningType.layer.cornerRadius = 4;
    labelWarnningType.layer.masksToBounds = YES;
    labelWarnningType.font = [UIFont systemFontOfSize:12];
    labelWarnningType.textAlignment = NSTextAlignmentCenter;
    labelWarnningType.textColor = [UIColor whiteColor];
    [self addSubview:labelWarnningType];
    _labelWarnningType = labelWarnningType;
}

-(void)setAgent:(IntelligenceAgent *)agent{
    _agent = agent;
    if (![agent.levelName isEqualToString:@"无"]) {
        _labelWarnningType.hidden = NO;
        _labelWarnningType.backgroundColor = agent.levelColor;
        _labelWarnningType.text = agent.levelName;
        _labelWarnningType.ve_width = [agent.levelName sizeWithAttributes:@{NSFontAttributeName:_labelWarnningType.font}].width;
        _timeLabel.ve_x = CGRectGetMaxX(_labelWarnningType.frame) + 5;
    }else{
        _labelWarnningType.hidden = YES;
        _timeLabel.ve_x = 5;
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"%@  %@", _columnName, agent.timePost];
    
    NSString *str = @"";
    if (agent.numberTitle.length > 0) {
        str = [NSString stringWithFormat:@"%@%@%@",agent.numberTitle,agent.title,agent.levelTip];
    }else{
        str = [NSString stringWithFormat:@"%@%@",agent.title,agent.levelTip];
    }
    _titleLabel.text = str;
    _timeLabel.ve_y = CGRectGetMaxY(_titleLabel.frame);
    _labelWarnningType.ve_y = _timeLabel.ve_y;
}

@end
