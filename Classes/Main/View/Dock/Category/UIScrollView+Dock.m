//
//  UIScrollView+Extension.m
//  GonganNew
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "UIScrollView+Dock.h"

@implementation UIScrollView (Dock)


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
        return YES;
    }else{
        return  NO;
    }
}


@end
