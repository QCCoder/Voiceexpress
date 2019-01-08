//
//  IntelligenceAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/25.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "IntelligenceAgent.h"
#import "UIColor+Utils.h"
#import "Receiver.h"
@implementation IntelligenceAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self)
    {
        // 解密
        NSString *encryptedStr = self.title;
        self.title = [DES3Util decrypt:encryptedStr];
        self.showTitle = [item valueForKey:kShowTitle];
        self.numberTitle = [item valueForKey:kNumberTitle];
        self.author = [item valueForKey:kAuthor];
        
        NSString *names = [item valueForKey:kReceiverNames];
        
        if(![names isKindOfClass:[NSNull class]]){
            if (names.length > 0){
                names = [names stringByReplacingOccurrencesOfString:@"{" withString:@""];
                names = [names stringByReplacingOccurrencesOfString:@"}" withString:@""];
                self.receiverNames = [[names componentsSeparatedByString:@","] copy];
            }
        }
        
        self.latestTimeReply  = [[item valueForKey:kTimeWarn] doubleValue];
        double temp1          = [[item valueForKey:kNewestTimeReply] doubleValue];
        self.newsTimeReply = temp1;
        self.newestTimeReply  = MAX(temp1, self.latestTimeReply);
        self.isReadMarkUpload = NO;
        if ([[item valueForKey:@"levelColor"] isEqualToString:@""]) {
            self.levelCode = @"";
            self.levelName = @"无";
            self.levelTip = @"";
            self.levelColor = nil;
        }else{
            
            self.levelCode = [[item valueForKey:@"levelCode"] copy];
            self.levelName = [[item valueForKey:@"levelName"] copy];
            self.levelTip = [[item valueForKey:@"levelTip"] copy];
            self.levelColor = [UIColor colorWithHexString:[[item valueForKey:@"levelColor"] copy]];
        }
    }
    return self;
}

@end
