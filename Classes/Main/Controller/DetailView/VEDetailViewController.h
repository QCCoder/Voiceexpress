//
//  VEDetailViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger VEDetailViewFromLatestAlert          = 201;       // 来自最新预警
static const NSInteger VEDetailViewFromSearchAlert          = 202;       // 来自舆情搜索
static const NSInteger VEDetailViewFromRecommendColumn      = 203;       // 来自推荐阅读
static const NSInteger VEDetailViewFromFavoriteAlerts       = 204;       // 来自收藏夹中的预警舆情
static const NSInteger VEDetailViewFromFavoriteRecommend    = 205;       // 来自收藏夹中的推荐阅读

@interface VEDetailViewController : BaseViewController<UIAlertViewDelegate>

@property(nonatomic, assign) NSInteger whichParent;
@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, strong) NSMutableArray *listDatas;

@property(nonatomic, copy)   NSString *columnID;                    // for recommend read
@property(nonatomic, strong) NSMutableSet *mayDeleteFavoriteItems;  // for Favorite

@end
