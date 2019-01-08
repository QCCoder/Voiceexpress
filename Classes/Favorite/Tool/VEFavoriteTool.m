//
//  VEFavoriteTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/11.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEFavoriteTool.h"
#import "FavoriteRecommendAgent.h"
#import "FavoriteAlertAgent.h"
@implementation VEFavoriteTool

/**
 *  获取收藏夹列表
 *
 *  @param param   参数
 *  @param index   0.普通预警 1.推荐阅读
 */
+(void)loadWarnFavoritesWithParam:(NSDictionary *)param index:(NSInteger)index resultInfo:(ResultInfoBlock)resultInfo
{
    NSString *url = @"WarnFavorites";
    [HttpTool postWithSessionClient:url param:param success:^(id JSON) {
        NSArray *array;
        if (index == 0) {
            array = [FavoriteAlertAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
        }else{
            array = [FavoriteRecommendAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
        }
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

@end
