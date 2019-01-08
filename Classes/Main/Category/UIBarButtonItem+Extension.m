//
//  UIBarButtonItem+Extension.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)
/**
 *  创建一个item
 *  
 *  @param target    点击item后调用哪个对象的方法
 *  @param action    点击item后调用target的哪个方法
 *  @param image     图片
 *  @param highImage 高亮的图片
 *
 *  @return 创建完的item
 */
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage
{
   
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img=[QCZipImageTool imageNamed:image];
    [btn setImage:img forState:UIControlStateNormal];
    [btn setImage:[QCZipImageTool imageNamed:highImage] forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize btnSize = img.size;
    CGRect frame = btn.frame;
    frame.size = btnSize;
    btn.frame = frame;
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
