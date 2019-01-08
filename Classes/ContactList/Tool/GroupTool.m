//
//  GroupTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "GroupTool.h"
@implementation GroupTool

+(void)loadGroupListWith:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupList" param:nil success:^(id JSON) {
        GroupList *list =[[GroupList alloc]init];
        list.allUsersList = [Group objectArrayWithKeyValuesArray:JSON[@"allUsersList"][@"list"]];
        list.commonContactsList = [Group objectArrayWithKeyValuesArray:JSON[@"commonContactsList"][@"list"]];
        list.customGroupList = [Group objectArrayWithKeyValuesArray:JSON[@"customGroupList"][@"list"]];
        
        if (list.commonContactsList == nil) {
            Group *group = [[Group alloc]init];
            group.groupName = @"常用联系人";
            group.groupId = 1 ;
            group.groupMember = [NSMutableArray array];
            list.commonContactsList = @[group];
        }
        
        resultInfo(YES,list);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)updateFavoriteContactWith:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomFavoriteContactsForGA" param:paramters success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)sortGroupListWith:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"ChangeSort" param:paramters success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)deleteGroupWithGroupId:(NSString *)groupId resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupDelete" param:@{@"customGroupId":groupId} success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)addCustomGroupWithName:(NSString *)groupName resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupAdd" param:@{@"customGroupName":groupName} success:^(id JSON) {
        Group *group = [Group objectWithKeyValues:JSON[@"customGroupId"]];
        group.groupName = groupName;
        resultInfo(YES,group);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)loadSelectContactsWithGroupId:(NSInteger)groupId resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"SelectContacts" param:@{@"customGroupId":[NSString stringWithFormat:@"%ld",groupId]} success:^(id JSON) {
        NSArray *array = [Group objectArrayWithKeyValuesArray:JSON[@"selectContactList"][@"list"]];
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)addCustomGroupContactWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupAddContact" param:paramters success:^(id JSON) {
        NSArray *array = [Group objectArrayWithKeyValuesArray:JSON[@"selectContactList"][@"list"]];
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)deleteCustomGroupContactWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupDeleteContact" param:paramters success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)updateCustomGroupNameWithParamters:(NSDictionary *)paramters resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"CustomGroupUpdate" param:paramters success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(NSPredicate *)predicateWithLeftPath:(NSString *)leftPath rightPath:(NSString *)rightPath{
    NSExpression *lhs = [NSExpression expressionForKeyPath:leftPath];
    NSExpression *rhs = [NSExpression expressionForConstantValue:rightPath];
    NSPredicate *predicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSContainsPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
    return predicate;
}

@end
