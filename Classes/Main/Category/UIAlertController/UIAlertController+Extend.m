//
//  UIAlertController+Extend.m
//  Alert
//
//  Created by 钱城 on 16/1/29.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import "UIAlertController+Extend.h"

@implementation UIAlertController (Extend)

+(void)showAlertWithtitle:(NSString *)title message:(NSString *)message target:(id)target alertActions:(id)alertActions{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if ([alertActions isKindOfClass:[NSArray class]]) {
        for (UIAlertAction *action in alertActions) {
            [alertController addAction:action];
        }
    }else if([alertActions isKindOfClass:[UIAlertAction class]]){
        [alertController addAction:alertActions];
    }
    [target presentViewController:alertController animated:YES completion:nil];
}

+(void)showActionSheetWithtitle:(NSString *)title message:(NSString *)message target:(id)target alertActions:(id)alertActions{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    if ([alertActions isKindOfClass:[NSArray class]]) {
        for (UIAlertAction *action in alertActions) {
            [alertController addAction:action];
        }
    }else if([alertActions isKindOfClass:[UIAlertAction class]]){
        [alertController addAction:alertActions];
    }
    [target presentViewController:alertController animated:YES completion:nil];
}

@end
