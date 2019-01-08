//
//  YLSwipeLockView.h
//  YLSwipeLockViewDemo
//
//  Created by 肖 玉龙 on 15/2/12.
//  Copyright (c) 2015年 Yulong Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LIGHTBLUE [UIColor colorWithRed:52.0/255.0 green:136/255.0 blue:174/255.0 alpha:1]

typedef NS_ENUM(NSUInteger, YLSwipeLockViewState) {
    YLSwipeLockViewStateNormal,
    YLSwipeLockViewStateWarning,
    YLSwipeLockViewStateSelected
};
@protocol YLSwipeLockViewDelegate;

@interface YLSwipeLockView : UIView
@property (nonatomic, weak) id<YLSwipeLockViewDelegate> delegate;
@property (nonatomic,copy) void(^selectedItem)(NSInteger index);
@property (nonatomic,copy) void(^cleanNode)();
@end


@protocol YLSwipeLockViewDelegate<NSObject>
@optional
-(YLSwipeLockViewState)swipeView:(YLSwipeLockView *)swipeView didEndSwipeWithPassword:(NSString *)password;
@end