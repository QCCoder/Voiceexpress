//
//  VETokenView.m
//  voiceexpress
//
//  Created by 钱城 on 15/11/3.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VETokenView.h"
#import "VETokenButton.h"
#import "UIView+Extension.h"
#define kmarginLeft 4

@interface VETokenView()
@property (nonatomic,strong) NSMutableArray *tokenBtnList;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIView *lineBK;
@property (nonatomic,weak) UIView *lineView;
@property (nonatomic,weak) UILabel *timeLabel;
@property (assign,nonatomic) BOOL isAmo;
@end

@implementation VETokenView

-(UIView *)lineView
{
    if (!_lineView) {
        UIView *class = [[UIView alloc]init];
        [class setBackgroundColor:RGBCOLOR(220, 220, 220)];
        [self addSubview:class];
        _lineBK = class;
        
        UIView *line = [[UIView alloc]init];
        [line setBackgroundColor:[UIColor colorWithHexString:Config(MainColor)]];
        [_lineBK addSubview:line];
        _lineView = line;
    }
    return _lineView;
}

-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        UILabel *class = [[UILabel alloc]init];
        [class setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:class];
        self.timeLabel = class;
    }
    return _timeLabel;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc]init];
        [label setText:@"舆情动态口令，竭诚保护您的上网安全"];
        [label setFont:[UIFont systemFontOfSize:13.0]];
        [label setTextColor:RGBCOLOR(136, 136, 136)];
        [self addSubview:label];
        self.titleLabel = label;
    }
    return _titleLabel;
}

-(NSMutableArray *)tokenBtnList
{
    if (!_tokenBtnList) {
        self.tokenBtnList = [NSMutableArray array];
    }
    return _tokenBtnList;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        for (int i = 0; i < 6; i++) {
            VETokenButton *btn = [[VETokenButton alloc]init];
            [self addSubview:btn];
            [self.tokenBtnList addObject:btn];
        }
        
    }
    return self;
}

-(void)setToken:(NSString *)token
{
    _token = token;
    
    char mychar[100];
    NSString * mystring = token;
    strcpy(mychar,(char *)[mystring UTF8String]);
    for (int i = 0; i < kDigits; i++) {
        UIButton *btn = self.tokenBtnList[i];
        [btn setTitle:[NSString stringWithFormat:@"%c",mychar[i]] forState:UIControlStateNormal];
    }
    
    if (_isAmo == YES) return;
    //调用drawRect
    [self setNeedsDisplay];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, 0, self.ve_width,[UIFont systemFontOfSize:13.0].lineHeight);
    for (int i=0; i<self.tokenBtnList.count; i++) {
        UIButton *btn = self.tokenBtnList[i];
        btn.ve_width = 41;
        btn.ve_height =50;
        btn.ve_x = i * (btn.ve_width + kmarginLeft);
        btn.ve_y = CGRectGetMaxY(_titleLabel.frame) + 10;
    }
    self.lineView.ve_height = 2;
    UIButton *btn = [self.tokenBtnList lastObject];
    [_lineBK setFrame:CGRectMake(0, CGRectGetMaxY(btn.frame)+10, self.ve_width, 2)];
    
    [self.timeLabel setFrame:CGRectMake(0, CGRectGetMaxY(_lineBK.frame) + 13, self.ve_width, 25)];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for (int i=0; i<self.tokenBtnList.count; i++) {
        UIButton *btn = self.tokenBtnList[i];
        btn.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 1.0, 0.0);
        
        [UIView animateKeyframesWithDuration:0.08 delay:i * 0.08 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            btn.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 1.0, 1.0);
        } completion:nil];
    }
    
    
    
    if(_second > 1){
        _lineView.ve_width = self.ve_width * _second/ 30;
    }else{
        _lineView.ve_width = 0;
    }
    [UIView animateWithDuration:(29 - _second) animations:^{
        _isAmo =YES;
        _lineView.ve_width = self.ve_width;
    } completion:^(BOOL finished) {
        _isAmo = NO;
    }];
}
-(void)setSecond:(NSInteger)second
{
    _second = second;
    NSString *str = [NSString stringWithFormat:@"动态口令将在%ld秒后改变",(30-second)];
    NSMutableAttributedString *attrStr= [[NSMutableAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:14.0],NSForegroundColorAttributeName:RGBCOLOR(67, 67, 67)}];
    [attrStr addAttributes:@{NSForegroundColorAttributeName:RGBCOLOR(250, 82, 12)} range:[str rangeOfString:[NSString stringWithFormat:@"%ld",(30-second)]]];
    [self.timeLabel setAttributedText:attrStr];
}

@end
