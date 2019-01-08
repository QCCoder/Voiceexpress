//
//  GroupListTableVC.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "QCTableViewController.h"
#import "GroupMember.h"
typedef NS_ENUM(NSInteger, GroupType){
    // 数值不要修改
    GroupTypeAll = 1,           // 收件箱
    GroupTypeContacts = 2,          // 常用
    GroupTypeCustom = 3,      // 自定义组
};


@interface GroupListTableVC : QCTableViewController

@property (nonatomic,assign) GroupType groupType;

/**
 *  isAdd YES:添加，NO:删除
 */
@property (nonatomic,strong) void(^favorite)(GroupType groupType,GroupMember *groupMember);
@property (nonatomic,copy) void(^selectedRow)(UIViewController *vc);

-(void)setContactMember:(GroupMember *)groupMember;

-(void)setSelectedData:(NSMutableArray *)array;

@property (nonatomic,strong) NSMutableArray *selectedList;

@property (nonatomic,copy) void(^getSelectedList)(GroupType groupType,NSMutableArray *array);
@end
