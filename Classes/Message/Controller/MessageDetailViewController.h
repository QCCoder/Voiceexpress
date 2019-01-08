//
//  MessageDetailViewController.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTool.h"
@interface MessageDetailViewController : BaseViewController

@property (nonatomic, strong) IntelligenceAgent *intelligAgent;

@property (nonatomic, assign) IntelligenceColumnType columnType;

@property (nonatomic, assign) BoxType boxType;

@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,copy) void(^deleteItem)(NSInteger index);

@end
