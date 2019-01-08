//
//  VESearchResultsViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-30.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SearchType)
{
    // 数值不要改变
    SearchTypeNormal         = 0,       // 舆情搜索
    SearchTypeLatestAlert    = 1,       // 舆情预警搜索
    SearchTypeRecommendRead  = 2,       // 推荐阅读搜索
};


@interface VESearchResultsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic)   NSString   *searchWord;
@property (assign, nonatomic) NSInteger  selectedScopeIndex;
@property (assign, nonatomic) SearchType searchType;

@end