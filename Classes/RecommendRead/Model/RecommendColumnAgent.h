//
//  RecommendSectionList.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendColumnAgent : NSObject


@property (nonatomic, copy)   NSString  *columnId;

@property (nonatomic, copy)   NSString  *columnTitle;

@property (nonatomic, copy)   NSString  *iconURL;

@property (nonatomic, assign) NSInteger newestArticleId;

@property (nonatomic, assign) NSInteger localNewestArticleId;

@end
