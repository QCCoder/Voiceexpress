//
//  TextPart.m
//  新浪微博
//
//  Created by apple on 15/7/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TextPart.h"

@implementation TextPart

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@",NSStringFromRange(self.range),self.text];
}

@end
