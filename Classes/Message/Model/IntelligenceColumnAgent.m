//
//  IntelligenceColumnAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "IntelligenceColumnAgent.h"

@implementation IntelligenceColumnAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        double aboutMeNewestTm  = [item[@"aboutMeNewestTm"] doubleValue];
        double receivedNewestTm = [item[@"receivedNewestTm"] doubleValue];
        double sendedNewestTm   = [item[@"sendedNewestTm"] doubleValue];
        self.newestTime = MAX((MAX(aboutMeNewestTm, receivedNewestTm)), sendedNewestTm);
        self.loacalNewestTime = 0;
        
        NSInteger type = [item[@"exchangeType"] integerValue];
        switch (type){
            case 1:
                self.columnType = IntelligenceColumnInstant;
                break;
                
            case 2:
                self.columnType = IntelligenceColumnDaily;
                break;
                
            case 3:
                self.columnType = IntelligenceColumnInternational;
                break;
                
            case 4:
                self.columnType = IntelligenceColumnAllIntelligence;
                break;
                
            default:
                self.columnType = IntelligenceColumnNone;
                break;
        }
    }
    return self;
}

@end
