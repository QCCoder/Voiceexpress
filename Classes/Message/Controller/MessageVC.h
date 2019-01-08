//
//  MessageVC.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/24.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "QCTableViewController.h"
#import "MessageTool.h"
@interface MessageVC : QCTableViewController

#define kCellHeight 78
//情报交互类型
@property (nonatomic,assign) IntelligenceColumnType columnType;
//已收，已发
@property (nonatomic,assign) BoxType boxType;

@property (nonatomic,copy) void(^refreshNewBox)(BoxType boxTpye,NSInteger countOfNewBox);

@property (nonatomic,copy) void(^selectedRow)(UIViewController *vc);

//获取数据
-(void)loadNewMessage;
-(void)markAll;
@end
