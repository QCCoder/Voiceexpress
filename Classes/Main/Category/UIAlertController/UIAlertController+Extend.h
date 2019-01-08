//
//  UIAlertController+Extend.h
//  Alert
//
//  Created by 钱城 on 16/1/29.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Extend)

+(void)showAlertWithtitle:(NSString *)title message:(NSString *)message target:(id)target alertActions:(id)alertActions;

+(void)showActionSheetWithtitle:(NSString *)title message:(NSString *)message target:(id)target alertActions:(id)alertActions;


@end
