//
//  IntelligenceColumnAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IntelligenceColumnType){
    // 数值不要改变
    IntelligenceColumnNone              = -1,
    IntelligenceColumnInstant           = 1,       // 网警信息快报
    IntelligenceColumnDaily             = 2,       // 网警每日舆情
    IntelligenceColumnInternational     = 3,       // 外宣每日舆情
    IntelligenceColumnAllIntelligence   = 4,       // 情报交互信息
};

@interface IntelligenceColumnAgent : NSObject

@property (nonatomic, assign) double newestTime;
@property (nonatomic, assign) double loacalNewestTime;
@property (nonatomic, assign) IntelligenceColumnType columnType;

- (id)initWithDictionary:(NSDictionary *)item;

@end
