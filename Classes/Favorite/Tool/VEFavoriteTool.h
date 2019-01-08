//
//  VEFavoriteTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/11.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEFavoriteTool : NSObject

/**
 *  获取收藏夹列表
 *
 *  @param param   参数
 *  @param index   0.普通预警 1.推荐阅读
 */
+ (void)loadWarnFavoritesWithParam:(NSDictionary *)param index:(NSInteger)index resultInfo:(ResultInfoBlock)resultInfo;

@end
