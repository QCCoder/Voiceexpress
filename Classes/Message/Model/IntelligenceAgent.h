//
//  IntelligenceAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/25.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "Agent.h"

@interface IntelligenceAgent : Agent

@property (nonatomic, copy)   NSString *author;
@property (nonatomic, strong) NSArray *receiverNames;
@property (nonatomic, strong) NSMutableArray *receivers;
@property (nonatomic, assign) double newestTimeReply;
@property (nonatomic, assign) double latestTimeReply;
@property (nonatomic, assign) double localTimeReply;
@property (nonatomic, assign) double newsTimeReply;
@property (nonatomic, assign) BOOL   isReadMarkUpload;

@property (nonatomic,copy ) NSString * levelName;
@property (nonatomic,copy ) NSString * levelCode;
@property (nonatomic,copy ) NSString * levelTip;
@property (nonatomic,copy) NSString *numberTitle;
@property (nonatomic,copy) NSString *showTitle;
@property (nonatomic,strong) UIColor  * levelColor;

@property (nonatomic,copy) NSString *suggest;
@property (nonatomic,assign) NSInteger suggestId;


- (id)initWithDictionary:(NSDictionary *)item;

@end
