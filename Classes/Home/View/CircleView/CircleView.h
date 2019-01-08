//
//  CircleView.h
//  HomeDemo
//
//  Created by 钱城 on 16/4/11.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Circle.h"
@interface CircleView : UIView

/**
 *  半径
 */
@property (assign,nonatomic) NSInteger radius;
/**
 *  弧度比
 */
@property (assign,nonatomic) NSInteger lineWith;

@property (nonatomic,strong) NSArray *dataList;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString* noRead;

@property (nonatomic,assign) float apa;

@property (nonatomic,assign) BOOL isNeedDraw;

-(void)stareAnimation;

-(void)reloadView;

@end
