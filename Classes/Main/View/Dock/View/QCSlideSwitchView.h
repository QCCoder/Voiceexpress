//
//  QCSlideSwitchView.h
//  Dock
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+Dock.h"
#import "QCDock.h"
#import "QCScrollView.h"
@interface QCSlideSwitchView : UIView

-(instancetype)initWithFrame:(CGRect)frame itemList:(NSArray *(^)())itemList;

@property (nonatomic,weak) QCScrollView *scrollView;

-(void)hideBoxImageView:(BOOL)hidden index:(NSInteger)index;

@property (nonatomic,copy) void(^selectIndex)(NSInteger selectIndex);

-(void)selectItem:(NSInteger)index;

@end
