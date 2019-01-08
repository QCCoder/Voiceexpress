//
//  RefreshHeader.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/22.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "RefreshHeader.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

@implementation RefreshHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lastUpdatedTimeLabel.textColor = TEXT_COLOR;
        self.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0];
        
        self.stateLabel.font = [UIFont boldSystemFontOfSize:13.0];
        self.stateLabel.textColor = TEXT_COLOR;
    }
    return self;
}


@end
