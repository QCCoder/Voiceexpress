//
//  DeviceItem.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "DeviceItem.h"

#define LIGHTBLUE [UIColor colorWithRed:151.0/255.0 green:151/255.0 blue:151/255.0 alpha:1]

@interface DeviceItem()
@property (nonatomic, strong)CAShapeLayer *outlineLayer;
@end

@implementation DeviceItem

-(CAShapeLayer *)outlineLayer
{
    if (_outlineLayer == nil) {
        _outlineLayer = [[CAShapeLayer alloc] init];
        _outlineLayer.strokeColor = LIGHTBLUE.CGColor;
        _outlineLayer.lineWidth = 0.5f;
        _outlineLayer.fillColor  = [UIColor clearColor].CGColor;
    }
    return _outlineLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.outlineLayer];
        self.status = QCDeviceTopStatusNormal;
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.outlineLayer.frame = self.bounds;
    UIBezierPath *outlinePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    self.outlineLayer.path = outlinePath.CGPath;
}

-(void)setStatus:(QCDeviceTopStatus)status{
    _status = status;
    if (status == QCDeviceTopStatusSelected) {
        self.outlineLayer.fillColor = RGBCOLOR(52, 136, 174).CGColor;
        self.outlineLayer.strokeColor = [UIColor clearColor].CGColor;
    }else if (status == QCDeviceTopStatusNormal){
        self.outlineLayer.fillColor = [UIColor clearColor].CGColor;
        self.outlineLayer.strokeColor = LIGHTBLUE.CGColor;
    }else{
        self.outlineLayer.fillColor = [UIColor redColor].CGColor;
        self.outlineLayer.strokeColor = [UIColor clearColor].CGColor;
    }
}


@end
