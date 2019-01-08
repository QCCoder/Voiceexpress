//
//  GroupTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupList.h"
@interface GroupTool : NSObject

+(void)loadGroupListWith:(ResultInfoBlock)resultInfo;

+(void)updateFavoriteContactWith:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

+(void)sortGroupListWith:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

+(void)deleteGroupWithGroupId:(NSString *)groupId resultInfo:(ResultInfoBlock)resultInfo;

+(void)addCustomGroupWithName:(NSString *)groupName resultInfo:(ResultInfoBlock)resultInfo;

+(void)loadSelectContactsWithGroupId:(NSInteger)groupId resultInfo:(ResultInfoBlock)resultInfo;

+(void)addCustomGroupContactWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

+(void)deleteCustomGroupContactWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

+(void)updateCustomGroupNameWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo;

+(NSPredicate *)predicateWithLeftPath:(NSString *)leftPath rightPath:(NSString *)rightPath;
@end
