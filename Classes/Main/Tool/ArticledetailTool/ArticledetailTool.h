//
//  ArticledetailTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AriticledetailRequest.h"
#import "Articledetail.h"
#import "Singleton.h"
#import "IntelligenceAgent.h"
@class ArticledetailTool;
@protocol ArticleDelegate <NSObject>

- (void)changeFontsize:(CGFloat )fontsize;
- (void)doDelete;
@end


@interface ArticledetailTool : NSObject

single_interface(ArticledetailTool)

/**
 *  加载文章详情
 *
 */
+ (void)loadArticleContentWithRequest:(AriticledetailRequest *)request success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  文章是否收藏详情
 *
 */
+ (void)loadWarnFavoriteWithRequest:(AriticledetailRequest *)request Result:(ResultBlock)success;

-(void)showList:(UIViewController *)vc agent:(Agent *)agent ;
-(void)showWithOrgList:(UIViewController *)vc agent:(Agent *)agent;
-(void)showWithDeleteList:(UIViewController *)vc agent:(Agent *)agent;
- (NSString *)retrieveShareContent;

+ (IntelligenceAgent *)getForward:(Agent *)agent;
@property (nonatomic,weak) id<ArticleDelegate> delegate;

@end
