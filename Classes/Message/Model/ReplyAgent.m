//
//  ReplyAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "ReplyAgent.h"

@implementation ReplyAgent

MJCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{
                           @"showTip":@"show",
                           };
    return dict;
}

-(void)setContent:(NSString *)content{
    _content = [DES3Util decrypt:content];
}

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        NSString *encryptedStr = [item valueForKey:kContent];
        self.content   = [DES3Util decrypt:encryptedStr];
        self.fromName  = [item valueForKey:kFromName];
        self.replyTime = [item valueForKey:kReplyTime];
        self.showTip   = [item valueForKey:kShowTip];
    }
    return self;
}

@end


@implementation ReplyGroupAgent

MJCodingImplementation

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        self.replyUserId   = [[item valueForKey:kReplyUserId] stringValue];
        self.replyUserName = [item valueForKey:kReplyUserName];
        
        NSMutableArray *groupList = [NSMutableArray array];
        
//        self.replyGroupList = [ReplyAgent objectArrayWithKeyValuesArray:item[@"replygroup"]];
        for (NSDictionary *replyItem in [item valueForKey:kReplygroupList])
        {
            ReplyAgent *replyAgent = [[ReplyAgent alloc] initWithDictionary:replyItem];
            [groupList addObject:replyAgent];
        }
        self.replygroup = groupList;
    }
    return self;
}

+(NSDictionary *)objectClassInArray{
    return @{
             @"replygroup": [ReplyAgent class]
             };
}

@end

@implementation ReplyGroup

@end