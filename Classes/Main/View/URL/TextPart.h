//
//  TextPart.h
//  新浪微博
//
//  Created by apple on 15/7/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextPart : NSObject

@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) BOOL isSpecial;
@end
