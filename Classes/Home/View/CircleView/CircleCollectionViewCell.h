//
//  CircleCollectionViewCell.h
//  voiceexpress
//
//  Created by cyyun on 16/5/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleChart.h"
#import "HomeCircle.h"

@interface CircleCollectionViewCell : UICollectionViewCell <CircleChartDelegate, CircleChartDataSource>

@property (nonatomic, strong) CircleChart *circleChart;
@property (nonatomic, strong) HomeCircle *homeCircle;

@property (nonatomic, assign) BOOL currCircle;

@property (nonatomic, assign) float apa;

@property (nonatomic, copy) void(^selectedCircle)(NSInteger index);

@end
