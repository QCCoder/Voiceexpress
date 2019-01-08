//
//  RecommendRead.h
//  voiceexpress
//
//  Created by fan on 14-8-23.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// 推荐阅读
@interface RecommendRead : NSManagedObject

@property (nonatomic, retain) NSString * articleId;
@property (nonatomic, retain) NSString * columnId;
@property (nonatomic, retain) NSNumber * warnType;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * firstTimeRead;

@end
