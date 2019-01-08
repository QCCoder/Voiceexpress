//
//  UIView+Extension.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

-(void)setVe_x:(CGFloat)ve_x
{
    CGRect frame = self.frame;
    frame.origin.x = ve_x;
    self.frame = frame;
}

-(void)setVe_y:(CGFloat)ve_y
{
    CGRect frame = self.frame;
    frame.origin.y = ve_y;
    self.frame = frame;
}

- (CGFloat)ve_x
{
    return self.frame.origin.x;
}

- (CGFloat)ve_y
{
    return self.frame.origin.y;
}

- (void)setVe_centerX:(CGFloat)ve_centerX
{
    CGPoint center = self.center;
    center.x = ve_centerX;
    self.center = center;
}

- (CGFloat)ve_centerX
{
    return self.center.x;
}

- (void)setVe_centerY:(CGFloat)ve_centerY
{
    CGPoint center = self.center;
    center.y = ve_centerY;
    self.center = center;
}

- (CGFloat)ve_centerY
{
    return self.center.y;
}

- (void)setVe_width:(CGFloat)ve_width
{
    CGRect frame = self.frame;
    frame.size.width = ve_width;
    self.frame = frame;
}

- (void)setVe_height:(CGFloat)ve_height
{
    CGRect frame = self.frame;
    frame.size.height = ve_height;
    self.frame = frame;
}

- (CGFloat)ve_height
{
    return self.frame.size.height;
}

- (CGFloat)ve_width
{
    return self.frame.size.width;
}

- (void)setVe_size:(CGSize)ve_size
{
    CGRect frame = self.frame;
    frame.size = ve_size;
    self.frame = frame;
}

- (CGSize)ve_size
{
    return self.frame.size;
}

- (void)setVe_origin:(CGPoint)ve_origin
{
    CGRect frame = self.frame;
    frame.origin = ve_origin;
    self.frame = frame;
}

- (CGPoint)ve_origin
{
    return self.frame.origin;
}
@end
