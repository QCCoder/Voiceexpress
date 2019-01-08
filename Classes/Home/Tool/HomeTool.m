//
//  HomeTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/20.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeTool.h"
#import "HomeCircle.h"
@implementation HomeTool

/**
 *  获取圈圈数据
 */
+(void)loadHomeTypeListWithTypeId:(NSString *)typeId resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"homeTypeList" param:@{@"listType":typeId} success:^(id JSON) {
        NSDictionary *dict = (NSDictionary *)JSON;
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        for (NSString *key in [dict allKeys]) {
            if (![key isEqualToString:@"result"]) {
                [mArr addObject:[HomeCircle objectWithKeyValues:dict[key]]];
            }
        }
        NSLog(@"mArr : %@", mArr);
        resultInfo(YES,mArr);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}


@end
