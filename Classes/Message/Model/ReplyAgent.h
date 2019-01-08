//
//  ReplyAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyAgent : NSObject

@property (nonatomic, copy)   NSString *content;
@property (nonatomic, copy)   NSString *fromName;
@property (nonatomic, copy)   NSString *replyTime;
@property (nonatomic, copy)   NSString *showTip;

- (id)initWithDictionary:(NSDictionary *)item;

@end

@interface ReplyGroupAgent : NSObject

@property (nonatomic, copy)   NSString *replyUserId;
@property (nonatomic, copy)   NSString *replyUserName;
@property (nonatomic, strong) NSArray *replygroup;

- (id)initWithDictionary:(NSDictionary *)item;

@end


@interface ReplyGroup : NSObject

@property (nonatomic,strong) NSArray *toMe;

@property (nonatomic,strong) NSArray *aboutMe;

@end

