//
//  PaomaView.h
//  voiceexpress
//
//  Created by cyyun on 16/4/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaomaView : UIView

- (instancetype)initWithFrame:(CGRect)frame andPaomaText:(NSString *)text;

- (void)start;

- (void)stop;

@end
