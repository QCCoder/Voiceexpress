//
//  Circle.m
//  HomeDemo
//
//  Created by 钱城 on 16/4/11.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import "Circle.h"


@implementation Circle

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{@"red":@"r",
                           @"green":@"g",
                           @"blue":@"b"
                           };
    return dict;
}

-(void)setRed:(double)red{
    _red = red / 255.0;
}

-(void)setGreen:(double)green{
    _green = green / 255.0;
}

-(void)setBlue:(double)blue{
    _blue = blue / 255.0;
}

@end
