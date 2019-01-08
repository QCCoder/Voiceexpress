//
//  CircleView.m
//  HomeDemo
//
//  Created by 钱城 on 16/4/11.
//  Copyright © 2016年 钱城. All rights reserved.
//

#import "CircleView.h"
#import "CircleSubTitleLabel.h"
#define kLineWidth 14
#define kRedValue 255

#define kGreenValue 0

#define kBlueValue 0
#define kSped 500
#define kColorMultiple 1
#define kFirstRound 0.1
#define kSecondRound 1.0

#define kNorRed 149 / 255.0
#define kNorGreen 189 / 255.0
#define kNorBlue 210 / 255.0

@interface CircleView()

@property (nonatomic,strong) NSMutableArray *layerList;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *numberLabel;

@property (nonatomic,strong) UILabel *subTitleLabel;

@property (nonatomic,strong) UILabel *oneTitleLabel;

@property (nonatomic,strong) NSMutableArray *itemLabelList;

@property (nonatomic,assign) BOOL isFirstLoad;

@property (nonatomic,strong) CAShapeLayer *yellowLayer;

@end


@implementation CircleView

-(NSMutableArray *)layerList
{
    if (!_layerList) {
        self.layerList = [[NSMutableArray alloc]init];
    }
    return _layerList;
}

-(NSMutableArray *)itemLabelList
{
    if (!_itemLabelList) {
        self.itemLabelList = [[NSMutableArray alloc]init];
    }
    return _itemLabelList;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFirstLoad = YES;
        [self setup];
    }
    return self;
}


-(void)awakeFromNib{
    [self setup];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    
    if (self.isSelected) {
        self.numberLabel.hidden = YES;
        self.titleLabel.ve_y = 50 * Main_Screen_Height / 667.0;
        self.titleLabel.ve_width = 100;
        self.titleLabel.ve_centerX = self.ve_width * 0.5;
        self.titleLabel.ve_height = 20;
        self.titleLabel.font = [UIFont systemFontOfSize:22 * Main_Screen_Width / 375.0];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        int i = 0;
        CGFloat labelX = 0;
        for (CircleSubTitleLabel *label in self.itemLabelList) {
            label.hidden = NO;
            label.ve_height = 15;
            label.ve_y = CGRectGetMaxY(self.titleLabel.frame) + i * 14 + 5;
            
            if (i == 0) {
                label.ve_centerX = self.titleLabel.ve_centerX;
                labelX = label.ve_x;
            }else{
                label.ve_x = labelX;
            }
            
            i++;
        }
        
    }else{
        self.numberLabel.hidden = NO;
        self.titleLabel.textColor = RGBCOLOR(149, 189, 201);
        self.titleLabel.font = [UIFont systemFontOfSize:24.0 * Main_Screen_Width / 375.0];
        self.titleLabel.ve_centerY = (self.ve_height - 50) * 0.5 + 15;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.ve_width = 60 * Main_Screen_Width / 375.0 ;
        self.titleLabel.ve_centerX = self.ve_width * 0.5;
        self.titleLabel.ve_height = self.ve_width - 12;
        
        _numberLabel.ve_y = self.ve_height - 23;
        _numberLabel.ve_height = 25;
        _numberLabel.ve_width = self.ve_width;
        
        for (CircleSubTitleLabel *label in self.itemLabelList) {
            label.hidden = YES;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    
    if (_dataList.count == 0) {
        return;
    }
    
    
    if (self.isSelected) {
        for (CAShapeLayer *layer in self.layerList) {
            [layer removeFromSuperlayer];
        }
        [self setColorWithRect:rect];
        
        [self initYellowLayer:rect];
        [self.layer addSublayer:_yellowLayer];
        if (_isNeedDraw) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * M_PI * _radius / kSped * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _yellowLayer.hidden = NO;
            });
        }else{
            _yellowLayer.hidden = NO;
        }
        
    }else{
        [_yellowLayer removeFromSuperlayer];
        _yellowLayer.hidden = YES;
        [self setNoColorWithRect:rect];
    }
    
}

//画圆
-(void)setColorWithRect:(CGRect)rect{
    CGFloat start = - M_PI_2;
    NSInteger i = 0;
    CGFloat end = - M_PI_2 -0.001;
    CGFloat time = 2 * M_PI * _radius / kSped ;//画1圈时间
    CGFloat tempTime = 2 * M_PI * _radius / kSped ;//画第一个圈时间
    for (Circle *item in _dataList){
        if (i != 0) {
            Circle *lastItem = _dataList[i -1];
            end -= M_PI * lastItem.percent / 50;
            tempTime -= time * lastItem.percent / 100.0 ;//减去画上一个圈弧度所需要的时间
        }
        
        if (item.percent == 0) {
            item.red = kNorRed * 255.0;
            item.green = kNorGreen * 255.0;
            item.blue = kNorBlue * 255.0;
        }
        
        if (!_isNeedDraw) {
            [self drawMoreArc:UIGraphicsGetCurrentContext() rect:rect radius:(rect.size.width - _lineWith) * 0.5 lineWidth:_lineWith startAngle:- M_PI_2 endAngle:end redValue:item.red greenValue:item.green blueValue:item.blue colorValue:1.0 colorMultiple:0];
        }else{
            [self addCircleLayer:rect lineWidth:_lineWith radius:(rect.size.width - _lineWith) * 0.5 startAngle:-M_PI_2 endAngle:end redValue:item.red greenValue:item.green blueValue:item.blue duration:tempTime needAnimation:_isNeedDraw after:0];
        }
        i++;
        start = end;
    }
}


-(void)initYellowLayer:(CGRect)rect{
    if (_yellowLayer == nil) {
        Circle *lastItem = _dataList[2];
        
        for (Circle *item in _dataList) {
            if (item.percent != 0) {
                lastItem = item;
                break;
            }
        }
        
        CAShapeLayer *lineLayer= [self addCircleLayer:rect lineWidth:_lineWith radius:(rect.size.width - _lineWith) * 0.5 startAngle:-M_PI_2 - 0.01 endAngle:-M_PI_2 redValue:lastItem.red greenValue:lastItem.green blueValue:lastItem.blue duration:0  needAnimation:NO after:0];
        _yellowLayer = lineLayer;
        [_yellowLayer removeFromSuperlayer];
        [self.layerList removeObject:lineLayer];
        lineLayer.hidden = YES;
    }
}

-(void)setNoColorWithRect:(CGRect)rect{
    rect.origin.y = 15;
    rect.size.height = rect.size.height - 50;
    [self addCircleLayer:rect lineWidth:(9.0 * Main_Screen_Width / 375.0) radius:(rect.size.height - (9.0 * Main_Screen_Width / 375.0)) * 0.5 startAngle:0 endAngle:-0.001 redValue:kNorRed greenValue:kNorGreen blueValue:kNorBlue duration:0.4 needAnimation:_isNeedDraw after:0.0];
}


#pragma mark 两种画圆方法
-(CAShapeLayer *)addCircleLayer:(CGRect)rect lineWidth:(CGFloat)lineWidth radius:(NSInteger)radius startAngle:(float)startAngle endAngle:(float)endAngle redValue:(double)red greenValue:(double)green blueValue:(double)blue duration:(CFTimeInterval)duration needAnimation:(BOOL)needAnimation after:(CGFloat)after {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5) radius:radius  startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.frame = rect;
    lineLayer.fillColor = [UIColor clearColor]. CGColor ;
    lineLayer.lineWidth = lineWidth;
    lineLayer.path = path.CGPath ;
    lineLayer.strokeColor = [UIColor colorWithRed:red  green:green blue:blue alpha:1.0].CGColor;
    lineLayer.lineCap = @"round";
    [self.layerList addObject:lineLayer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (needAnimation) {
            CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath:NSStringFromSelector (@selector (strokeEnd))];
            ani.fromValue = @0;
            ani.toValue = @1;
            ani.duration = duration;
            [lineLayer addAnimation:ani forKey:NSStringFromSelector ( @selector (strokeEnd))];
        }
        
        [self.layer addSublayer:lineLayer];
        
    });
    return lineLayer;
}

-(void)drawMoreArc:(CGContextRef)ctx rect:(CGRect)rect radius:(NSInteger)r lineWidth:(float)width startAngle:(float)startAngle endAngle:(float)endAngle redValue:(double)red greenValue:(double)green blueValue:(double)blue colorValue:(double)colorValue  colorMultiple:(NSInteger)multiple{
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, r, startAngle, endAngle, 0);
    CGContextSetLineWidth(ctx, width);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetRGBStrokeColor(ctx, red, green, blue, _apa);
    CGContextStrokePath(ctx);
}



//初始化视图，set get
-(void)setNoRead:(NSString *)noRead{
    _noRead = noRead;
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@未读",noRead]];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:27.0 * Main_Screen_Width / 375.0] range:NSMakeRange(0, noRead.length)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0* Main_Screen_Width / 375.0] range:NSMakeRange(noRead.length, 2)];
    _numberLabel.attributedText = attributeStr;
    
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

-(void)setDataList:(NSArray *)dataList{
    _dataList = dataList;
    
    CGFloat maxWidth=0;
    NSInteger i = 0;
    for (Circle *item in dataList) {
        CircleSubTitleLabel *label = self.itemLabelList[i];
        label.number = [NSString stringWithFormat:@"%.0f%%",item.percent];
        label.title = item.title;
        label.ve_width = MAX(maxWidth, [label.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0]}].width) + 30;
        i++;
    }
    
    for (CAShapeLayer *layer in self.layerList) {
        [layer removeFromSuperlayer];
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        _titleLabel.alpha = 1.0;
        _numberLabel.alpha = 1.0;
        for (CircleSubTitleLabel *label in self.itemLabelList) {
            label.alpha = 1.0;
        }
    }];
    [self setNeedsDisplay];
}

-(void)stareAnimation{
    [self setNeedsDisplay];
}

-(void)setup{
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.alpha = 0.0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _numberLabel = [[UILabel alloc]init];
    _numberLabel.alpha = 0.0;
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.textColor = RGBCOLOR(149, 189, 201);
    
    [self addSubview:_numberLabel];
    
    [self addItemLabel];
}


-(void)addItemLabel{
    for (int i=0; i<3; i++) {
        CircleSubTitleLabel *itemLabel = [[CircleSubTitleLabel alloc]init];
        itemLabel.alpha = 0.0;
        [self addSubview:itemLabel];
        [self.itemLabelList addObject:itemLabel];
    }
}

-(void)reloadView{
    [self setNeedsDisplay];
}

@end
