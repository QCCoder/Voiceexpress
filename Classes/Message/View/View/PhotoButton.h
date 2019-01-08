//
//  PhotoButton.h
//  Theme
//
//  Created by 钱城 on 15/12/7.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageMargin 5

@interface PhotoButton : UIButton

@property (nonatomic,assign) BOOL hiddDeleteBtn;

@property (nonatomic,copy) void(^deleteBtnClick)(NSInteger index);

@end
