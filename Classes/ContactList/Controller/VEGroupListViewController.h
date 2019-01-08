//
//  VEGroupListViewController.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEGroupListViewController : BaseViewController


@property (nonatomic,copy) void(^selectedContacts)(NSMutableArray *array);

@property (nonatomic,strong) NSMutableArray *selectedList;

-(NSArray *)getAllUser;

@end
