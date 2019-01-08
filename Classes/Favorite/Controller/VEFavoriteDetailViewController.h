//
//  VEFavoriteDetailViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-6.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger FavoriteDetailViewFavoriteFromAlerts    = 0;       // 普通预警
static const NSInteger FavoriteDetailViewFavoriteFromRecommend = 1;       // 推荐阅读

@interface VEFavoriteDetailViewController : BaseViewController

@property (nonatomic, assign) NSInteger comeFrom;

@property (nonatomic,copy) void(^favorite)();
@end
