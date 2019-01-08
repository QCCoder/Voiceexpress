//
//  PromptView.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "PromptView.h"

#define kMargin 0.14 * Main_Screen_Width
#define kIndictorWH Main_Screen_Width / 16
#define kBorderX 13
#define kBorderY 13
#define kOffsetY 66
@interface PromptView()

@property (nonatomic,weak) UILabel *textLabel;

@end


@implementation PromptView

-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        UIActivityIndicatorView *name = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(kBorderX - 1, kBorderY, kIndictorWH, kIndictorWH)];
        [self addSubview:name];
        self.indicatorView = name;
    }
    return _indicatorView;
}

-(UILabel *)textLabel
{
    if (!_textLabel) {
        UILabel *name = [[UILabel alloc]init];
        [name setTextColor:[UIColor whiteColor]];
        [name setFont:[UIFont systemFontOfSize:15.0]];
        [self addSubview:name];
        self.textLabel = name;
    }
    return _textLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        [self.indicatorView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor darkTextColor]];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (_msg.length == 0) {
        self.width = self.indicatorView.width + 2 * kBorderX;
    }else{
        NSString *text = self.textLabel.text;
        CGSize size = [text sizeWithFont:self.textLabel.font];
        [self.textLabel setFrame:CGRectMake(CGRectGetMaxX(self.indicatorView.frame) + 10, 0, size.width, size.height)];
        self.textLabel.center = CGPointMake(self.textLabel.center.x, self.indicatorView.center.y);
        self.width = CGRectGetMaxX(self.textLabel.frame) + 20;
    }
    self.center = CGPointMake(Main_Screen_Width * 0.5, Main_Screen_Height * 0.5 - kOffsetY);
    self.height = self.indicatorView.ve_height + 2 * kBorderY;
    
}

-(void)setMsg:(NSString *)msg
{
    _msg = msg;
    self.textLabel.text = msg;
    [self setNeedsDisplay];
}


+ (void)startShowPromptViewWithTip:(NSString *)tip view:(UIView *)view
{
    PromptView *promptView = [[PromptView alloc]init];
    promptView.msg = tip;
    [view addSubview:promptView];
    promptView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        promptView.alpha = 0.9;
        [promptView.indicatorView startAnimating];
    }];
}

+ (void)hidePromptFromView:(UIView *)view
{
    if (view == nil){
        view = [[UIApplication sharedApplication].windows lastObject];
    }else{
        view = [view.subviews lastObject];
    }
    
    [UIView animateWithDuration:2.0
                     animations:^{
                         view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }
     ];
}

+ (void)hidePrompt{
    [self hidePromptFromView:nil];
}

@end
