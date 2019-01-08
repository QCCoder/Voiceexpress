//
//  Circle.h
//  HomeDemo
//
//  Created by 钱城 on 16/4/11.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+Extension.h"
/*** MainScreen Height Width */
#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define Main_Screen_Width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度

//颜色（RGB）
#define RGBCOLOR(r,g,b)          [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface Circle : NSObject

@property (nonatomic,assign) CGFloat percent;

@property (nonatomic,copy) NSString* numberOfNoRead;

@property (nonatomic,assign) double red;

@property (nonatomic,assign) double green;

@property (nonatomic,assign) double blue;

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *subTitle;

@end
