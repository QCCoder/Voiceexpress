//
//  Group.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupMember.h"
@interface Group : NSObject

@property (nonatomic,assign) NSInteger groupId;

@property (nonatomic,copy) NSString *groupName;

@property (nonatomic,strong) NSMutableArray *groupMember;

@end
