//
//  RecommendColumn.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-8-25.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecommendColumn : NSManagedObject

@property (nonatomic, retain) NSString * columnId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * newestArticleId;

@end
