//
//  HomeCircleItemView.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Circle.h"
typedef NS_ENUM(NSInteger, CircleType){
    // 数值不要修改
    CircleTypeGreen = 1,
    CircleTypeYellow = 2,
    CircleTypeRed = 3,
};


@interface HomeCircleItemView : UIView

@property (nonatomic,assign) CircleType type;

@property (nonatomic,copy) Circle *circle;

@end
