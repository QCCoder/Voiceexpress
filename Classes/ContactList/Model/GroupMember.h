//
//  GroupMember.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupMember : NSObject

@property (nonatomic,assign) NSInteger uid;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) NSInteger cid;

@property (nonatomic,assign) BOOL isContact;

@property (nonatomic,copy) NSString *fullNamePinYin;

@property (nonatomic,copy) NSString *firstLetterPinYin;

@property (nonatomic,assign) BOOL isSelected;

@end
