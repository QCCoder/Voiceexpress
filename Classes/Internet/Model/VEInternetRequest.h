//
//  VEInternetRequest.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/24.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEInternetRequest : NSObject

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,assign) NSInteger limit;

@property (nonatomic,copy) NSString *infoTypes;

@property (nonatomic,assign) NSInteger dept;

@property (nonatomic,assign) NSInteger areaType;

@end
