//
//  PromptView.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptView : UIView

@property (nonatomic,copy) NSString *msg;

@property (nonatomic,weak) UIActivityIndicatorView *indicatorView;

+ (void)startShowPromptViewWithTip:(NSString *)tip view:(UIView *)view;

+ (void)hidePrompt;

+ (void)hidePromptFromView:(UIView *)view;
@end
