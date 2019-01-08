//
//  VETokenRespons.h
//  voiceexpress
//
//  Created by 钱城 on 15/11/4.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VETokenRespons : NSObject

@property (nonatomic,assign) NSInteger isopen;
@property (nonatomic,assign) NSInteger result;
@property (nonatomic,assign) NSString *serverTime;
@property (nonatomic,copy) NSString *userkey;
@end
