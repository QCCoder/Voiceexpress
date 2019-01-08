//
//  Dock.h
//  GonganNew
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCDockItem.h"

@class QCDock;
@protocol QCDockDelegate <NSObject>
@optional

- (void)dockItemClick:(QCDock *)dockItem selectIndex:(NSInteger)selectIndex;

@end

@interface QCDock : UIView

@property (assign,nonatomic) NSInteger selectIndex;
// 添加一个选项卡
- (void)addItemWithTitle:(NSString *)title index:(NSInteger)index;
- (void)hideBoxImageView:(BOOL)hidden index:(NSInteger)index;
@property (nonatomic,weak) id<QCDockDelegate> delegate;
@end
