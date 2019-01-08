//
//  RecommendAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "RecommendAgent.h"
@implementation RecommendAgent

MJCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{
                           @"articleId":@"aid",
                           @"timePost":@"tmPost"
                           };
    return dict;
}

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self)
    {
        self.thumbImageUrl = [item valueForKey:kThumbImageUrl];
        self.imageUrls = [[[item valueForKey:kImageUrls] valueForKey:kImageUrl] copy];
    }
    return self;
}

@end
