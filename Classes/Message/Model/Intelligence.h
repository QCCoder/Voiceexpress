//
//  Intelligence.h
//  voiceexpress
//
//  Created by fan on 14-8-23.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// 情报交互
@interface Intelligence : NSManagedObject

@property (nonatomic, retain) NSString * articleId;
@property (nonatomic, retain) NSNumber * warnType;
@property (nonatomic, retain) NSNumber * boxType;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * latestTimeReply;
@property (nonatomic, retain) NSNumber * isReadMarkUpload;
@property (nonatomic, retain) NSNumber * firstTimeRead;

@end
