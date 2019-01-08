//
//  CircleChart.h
//  voiceexpress
//
//  Created by cyyun on 16/5/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChart;
@protocol CircleChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSlicesInCircleChart:(CircleChart *)circleChart;
- (CGFloat)circleChart:(CircleChart *)circleChart valueForSliceAtIndex:(NSUInteger)index;
@optional
- (UIColor *)circleChart:(CircleChart *)circleChart colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)circleChart:(CircleChart *)circleChart textForSliceAtIndex:(NSUInteger)index;
@end

@protocol CircleChartDelegate <NSObject>
@optional
- (void)circleChart:(CircleChart *)circleChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)circleChart:(CircleChart *)circleChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)circleChart:(CircleChart *)circleChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)circleChart:(CircleChart *)circleChart didDeselectSliceAtIndex:(NSUInteger)index;
@end

@interface CircleChart : UIView
@property(nonatomic, weak) id<CircleChartDataSource> dataSource;
@property(nonatomic, weak) id<CircleChartDelegate> delegate;
@property(nonatomic, assign) CGFloat startPieAngle;
@property(nonatomic, assign) CGFloat animationSpeed;
@property(nonatomic, assign) CGPoint pieCenter;
@property(nonatomic, assign) CGFloat pieRadius;
@property(nonatomic, assign) BOOL    showLabel;
@property(nonatomic, strong) UIFont  *labelFont;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong) UIColor *labelShadowColor;
@property(nonatomic, assign) CGFloat labelRadius;
@property(nonatomic, assign) CGFloat selectedSliceStroke;
@property(nonatomic, assign) CGFloat selectedSliceOffsetRadius;
@property(nonatomic, assign) BOOL    showPercentage;
- (id)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(UIColor *)color;

- (void)setSliceSelectedAtIndex:(NSInteger)index;
- (void)setSliceDeselectedAtIndex:(NSInteger)index;

@end;
