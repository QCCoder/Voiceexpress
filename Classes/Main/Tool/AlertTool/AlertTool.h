//
//  AlertTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertTool : NSObject


+(void)showAlertToolWithCode:(NSInteger)code;

+(void)showAlertToolWithMessage:(NSString *)msg;

+(NSString *)getHttpMsg:(NSInteger)code;
@end
