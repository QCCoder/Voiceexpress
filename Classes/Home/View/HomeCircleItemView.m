//
//  HomeCircleItemView.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeCircleItemView.h"

#define LIGHTGREEN [UIColor colorWithRed:36.0/255.0 green:196/255.0 blue:112/255.0 alpha:1]
#define LIGHTYELLOW [UIColor colorWithRed:232.0/255.0 green:209/255.0 blue:57/255.0 alpha:1]
#define LIGHTRED [UIColor colorWithRed:245.0/255.0 green:89/255.0 blue:95/255.0 alpha:1]

@interface HomeCircleItemView()

@property (nonatomic, strong)CAShapeLayer *outlineLayer;

@end

@implementation HomeCircleItemView

-(CAShapeLayer *)outlineLayer
{
    if (_outlineLayer == nil) {
        _outlineLayer = [[CAShapeLayer alloc] init];
        
        _outlineLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.46).CGColor;
        _outlineLayer.lineWidth = 2.0f;
        
        switch (self.tag) {
            case CircleTypeRed:
                _outlineLayer.fillColor  = LIGHTRED.CGColor;
                break;
            case CircleTypeYellow:
                _outlineLayer.fillColor  = LIGHTYELLOW.CGColor;
                break;
            default:
                _outlineLayer.fillColor  = LIGHTGREEN.CGColor;
                break;
        }
    }
    return _outlineLayer;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self.layer addSublayer:self.outlineLayer];
    }
    return self;
}



-(void)layoutSubviews{
    [super layoutSubviews];

    self.outlineLayer.frame = self.bounds;
    UIBezierPath *outlinePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    self.outlineLayer.path = outlinePath.CGPath;
}

-(void)setCircle:(Circle *)circle{
    self.outlineLayer.fillColor = [UIColor colorWithRed:circle.red green:circle.green blue:circle.blue alpha:1.0].CGColor;
       [self setNeedsLayout];
}



@end
