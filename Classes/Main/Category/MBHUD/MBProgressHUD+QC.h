//
//  MBProgressHUD+QC.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/25.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (QC)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;
+ (void)hideHUDWithDelay:(NSTimeInterval)time;

+(void)changeToSuccessWithHUD:(MBProgressHUD *)hud Message:(NSString *)message;

+(void)changeToErrorWithHUD:(MBProgressHUD *)hud Message:(NSString *)message;

@end
