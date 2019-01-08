//
//  Warn.h
//  voiceexpress
//
//  Created by fan on 14-8-23.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// 预警（最新预警、推荐阅读、舆情搜索）
@interface Warn : NSManagedObject

@property (nonatomic, retain) NSString * articleId;
@property (nonatomic, retain) NSString * articleContent;
@property (nonatomic, retain) NSNumber * warnType;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * firstTimeRead;

@end
