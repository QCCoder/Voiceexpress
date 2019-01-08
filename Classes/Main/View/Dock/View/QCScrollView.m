//
//  QCScrollView.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/25.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "QCScrollView.h"

@interface QCScrollView()<UIGestureRecognizerDelegate>

@end

@implementation QCScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.panGestureRecognizer.delegate = self;
    }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return !_scroll;
    return YES;
}

@end
