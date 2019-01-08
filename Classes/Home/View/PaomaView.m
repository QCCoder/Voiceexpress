//
//  PaomaView.m
//  voiceexpress
//
//  Created by cyyun on 16/4/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "PaomaView.h"

@implementation PaomaView
{
    CGRect _rectMark1;
    CGRect _rectMark2;
    
    NSMutableArray *_labelArr;
    NSTimeInterval _timeInterval;
    
    BOOL isStop;
}

- (instancetype)initWithFrame:(CGRect)frame andPaomaText:(NSString *)text
{
    if (self = [super initWithFrame:frame]) {
        text = [NSString stringWithFormat:@"   %@   ", text];
        
        _timeInterval = [self displayDurationForString:text];
        self.clipsToBounds = YES;
        
        UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectZero];
        textLab.textColor = [UIColor whiteColor];
        textLab.font = [UIFont systemFontOfSize:14];
        textLab.text = text;
        
        CGSize sizeOfText = [textLab sizeThatFits:CGSizeZero];
        
        _rectMark1 = CGRectMake(0, 0, sizeOfText.width, self.bounds.size.height);
        _rectMark2 = CGRectMake(_rectMark1.origin.x + _rectMark1.size.width, 0, sizeOfText.width, self.bounds.size.height);
        textLab.frame = _rectMark1;
        [self addSubview:textLab];
        
        _labelArr = [NSMutableArray arrayWithObject:textLab];
        
        BOOL useReserve = sizeOfText.width > frame.size.width ? YES : NO;
        
        if (useReserve) {
            UILabel *reserveTextLab = [[UILabel alloc] initWithFrame:_rectMark2];
            reserveTextLab.textColor = [UIColor whiteColor];
            reserveTextLab.font = [UIFont systemFontOfSize:14];
            reserveTextLab.text = text;
            [self addSubview:reserveTextLab];
            
            [_labelArr addObject:reserveTextLab];
            [self paomaAnimate];
        }
    }
    return self;
}

- (void)paomaAnimate
{
    if (!isStop) {
        UILabel *lbindex0 = _labelArr[0];
        UILabel *lbindex1 = _labelArr[1];
        
        [UIView transitionWithView:self duration:_timeInterval options:UIViewAnimationOptionCurveLinear animations:^{
            
            lbindex0.frame = CGRectMake(-_rectMark1.size.width, 0, _rectMark1.size.width, _rectMark1.size.height);
            lbindex1.frame = CGRectMake(lbindex0.frame.origin.x + lbindex0.frame.size.width, 0, lbindex1.frame.size.width, lbindex1.frame.size.height);
            
            
        } completion:^(BOOL finished) {
            
            lbindex0.frame = _rectMark2;
            lbindex1.frame = _rectMark1;
            
            [_labelArr replaceObjectAtIndex:0 withObject:lbindex1];
            [_labelArr replaceObjectAtIndex:1 withObject:lbindex0];
            [self paomaAnimate];
        }];
    }
}

- (void)start
{
    isStop = NO;
    UILabel *lbindex0 = _labelArr[0];
    UILabel *lbindex1 = _labelArr[1];
    lbindex0.frame = _rectMark2;
    lbindex1.frame = _rectMark1;
    
    [_labelArr replaceObjectAtIndex:0 withObject:lbindex1];
    [_labelArr replaceObjectAtIndex:0 withObject:lbindex0];
    [self paomaAnimate];
}

- (void)stop
{
    isStop = YES;
}

- (NSTimeInterval)displayDurationForString:(NSString *)text
{
    return text.length / 5.0;
}


@end
