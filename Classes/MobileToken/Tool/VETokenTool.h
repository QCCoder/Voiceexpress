//
//  VETokenTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/11/4.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VETokenTool : UIView

+(void)getTokenWithUserId:(NSInteger )userId;
+(long)getTimestamp;
+(NSDictionary *)getServiceTime;
@end
