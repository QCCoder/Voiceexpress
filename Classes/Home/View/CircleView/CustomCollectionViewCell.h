//
//  CustomCollectionViewCell.h
//  CustomLayout
//
//  Created by Fay on 16/3/12.
//  Copyright © 2016年 Fay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "HomeCircle.h"
@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic,copy) HomeCircle *homeCircle;

@property (nonatomic,assign) BOOL currCircle;

@property (nonatomic,assign) float apa;

@property (nonatomic,copy) void(^selectedCircle)(NSInteger index);
@end