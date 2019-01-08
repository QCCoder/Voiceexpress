//
//  WarnAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "WarnAgent.h"


@implementation WarnAgent

MJCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{@"webURL":@"url",
                           @"articleId":@"aid",
                           @"timePost":@"tmPost",
                           @"warnLevel":@"level"
                           };
    return dict;
}


- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self)
    {
        self.author     = [item valueForKey:kAuthor];
        self.tmWarn   = [[item valueForKey:kTimeWarn] stringValue];
        self.url     = [item valueForKey:kWebURL];
        self.site       = [item valueForKey:kSite];
        self.localTag   = [item valueForKey:kLocalTag];
    }
    return self;
}

@end
