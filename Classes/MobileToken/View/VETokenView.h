//
//  VETokenView.h
//  voiceexpress
//
//  Created by 钱城 on 15/11/3.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

//颜色（RGB）
#define RGBCOLOR(r,g,b)          [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define kDigits 6

@interface VETokenView : UIView

@property (nonatomic,assign) NSString* token;
@property (nonatomic,assign) NSInteger second;
@end
