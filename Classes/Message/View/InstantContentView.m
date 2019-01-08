//
//  InstantContentView.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "InstantContentView.h"

@interface InstantContentView()

@property (nonatomic,weak) UIImageView *titleImage;

@property (nonatomic,weak) UILabel *showTitleLabel;

@property (nonatomic,weak) UILabel *warnLabel;

@property (nonatomic,weak) UILabel *deptLabel;

@property (nonatomic,weak) UILabel *timeLabel;

@property (nonatomic,weak) UIView *line;

@property (nonatomic,weak) UIImageView *imageView;

@property (nonatomic,weak) UILabel *countImageLabel;

@property (nonatomic,weak) UILabel *titleLabel;

@end

@implementation InstantContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *titleImage = [[UIImageView alloc]initWithImage:Image(Icon_Wangan)];
    titleImage.ve_width = 234;
    titleImage.ve_height = 40;
    titleImage.centerX = Main_Screen_Width / 2;
    titleImage.ve_y = 33;
    titleImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:titleImage];
    _titleImage = titleImage;
    
    UILabel *showTitleLabel = [[UILabel alloc]init];
    showTitleLabel.ve_height = 21;
    showTitleLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:showTitleLabel];
    _showTitleLabel = showTitleLabel;
    
    UILabel *warnLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 26, 14)];
    warnLabel.font = [UIFont systemFontOfSize:12.0];
    warnLabel.layer.cornerRadius = 3;
    warnLabel.layer.masksToBounds = YES;
    warnLabel.textColor = [UIColor whiteColor];
    [self addSubview:warnLabel];
    _warnLabel = warnLabel;
    
    UILabel *deptLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, 150, 21)];
    deptLabel.font = [UIFont systemFontOfSize:13.0];
    deptLabel.text = Config(DeptName);
    [self addSubview:deptLabel];
    _deptLabel = deptLabel;
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(Main_Screen_Width - 13 - 120, 0, 120, 21)];
    timeLabel.font = [UIFont systemFontOfSize:13.0];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(12, 0, Main_Screen_Width - 24, 1)];
    line.backgroundColor = [UIColor blackColor];
    [self addSubview:line];
    _line = line;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Main_Screen_Width - 20, 21)];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _showTitleLabel.ve_y = CGRectGetMaxY(_titleImage.frame) + 20;
    _warnLabel.centerY = _showTitleLabel.ve_centerY;
    if (_agent.showTitle.length > 0) {
        _showTitleLabel.hidden = NO;
        CGFloat W = [_showTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_showTitleLabel.font}].width;
        _showTitleLabel.ve_width = W;
        
        if (_warnLabel.hidden) {
            _showTitleLabel.ve_x = (Main_Screen_Width - W) / 2;
        }else{
            _showTitleLabel.ve_x = (Main_Screen_Width - W - 26) / 2;
            _warnLabel.ve_x = CGRectGetMaxX(_showTitleLabel.frame) + 2;
        }
    }else{
        _showTitleLabel.hidden = YES;
        _warnLabel.centerX = Main_Screen_Width / 2;
        _warnLabel.ve_y = CGRectGetMaxY(_titleImage.frame) + 20;
    }
    
    if (_showTitleLabel.hidden && _warnLabel.hidden) {
        _deptLabel.ve_y = _showTitleLabel.ve_y;
    }else{
        _deptLabel.ve_y = MAX(CGRectGetMaxY(_showTitleLabel.frame), CGRectGetMaxY(_warnLabel.frame)) + 3;
    }
    
    _timeLabel.ve_y = _deptLabel.ve_y;
    _line.ve_y = CGRectGetMaxY(_deptLabel.frame) + 3;
    
    _titleLabel.ve_y = CGRectGetMaxY(_line.frame) + 15;
    
    self.ve_height = CGRectGetMaxY(_titleLabel.frame);
}

-(void)setAgent:(IntelligenceAgent *)agent{
    _agent = agent;
    
    if (agent.showTitle.length > 0) {
        _showTitleLabel.text = [NSString stringWithFormat:@"(%@)",agent.showTitle];
        _showTitleLabel.hidden = NO;
    }else{
        _showTitleLabel.hidden = YES;
    }
    
    if (![agent.levelName isEqualToString:@"无"]) {
        _warnLabel.text = agent.levelName;
        _warnLabel.backgroundColor = agent.levelColor;
        _warnLabel.hidden = NO;
    }else{
        _warnLabel.hidden = YES;
    }
    
    NSString *year = [agent.timePost substringToIndex:4];
    NSString *monuth = [agent.timePost substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [agent.timePost substringWithRange:NSMakeRange(8, 2)];
    _timeLabel.text = [NSString stringWithFormat:@"%@年%@月%@日",year,monuth,day];
    
    _titleLabel.text = agent.title;
    _titleLabel.ve_height = [agent.title boundingRectWithSize:CGSizeMake(_titleLabel.ve_width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.height;
    
    
    [self setNeedsLayout];
}
@end
