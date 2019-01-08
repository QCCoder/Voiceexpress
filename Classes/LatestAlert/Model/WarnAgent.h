//
//  WarnAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "Agent.h"


@interface WarnAgent : Agent

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *site;

@property (nonatomic, copy) NSString *tmWarn;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *localTag;

- (id)initWithDictionary:(NSDictionary *)item;

@end