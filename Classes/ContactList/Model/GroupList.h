//
//  GroupList.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"
@interface GroupList : NSObject

@property (nonatomic,strong) NSArray *allUsersList;

@property (nonatomic,strong) NSArray *commonContactsList;

@property (nonatomic,strong) NSArray *customGroupList;

@end
