//
//  RecommendAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agent.h"

@interface RecommendAgent : Agent

@property (nonatomic, strong)   NSArray  *imageUrls;
@property (nonatomic, copy)     NSString *thumbImageUrl;

- (id)initWithDictionary:(NSDictionary *)item;

@end
