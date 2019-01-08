//
//  DeviceTopView.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "DeviceTopView.h"
@interface DeviceTopView()

@property (nonatomic,strong) NSMutableArray *topViews;

@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,weak) UIView *topView;

@end

@implementation DeviceTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


-(void)setup{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 31, 31)];
    [self addSubview:topView];
    _topView = topView;
    _topViews = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i < 9 ; i++) {
        DeviceItem *view = [[DeviceItem alloc]init];
        [self.topView addSubview:view];
        [_topViews addObject:view];
    }
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 150, 15)];
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    titleLabel.textColor = RGBCOLOR(102, 120, 120);
    titleLabel.text = @"绘制解锁图案";
    titleLabel.height = titleLabel.font.lineHeight;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _topView.ve_centerX = self.ve_width * 0.5;
    _titleLabel.ve_centerX = self.ve_width * 0.5;
    NSInteger i = 0;
    for (UIView *view in _topViews) {
        NSInteger row = i % 3;
        NSInteger col = i / 3;
        view.frame = CGRectMake(row * (7 + 5), col * (7 + 5), 7, 7);
        i++;
    }
    
}

-(void)setPassword:(NSString *)password{
    _password = password;
    NSString *temp = nil;
    for (int i = 0; i < password.length ; i++) {
        temp = [password substringWithRange:NSMakeRange(i, 1)];
        NSInteger index = [temp integerValue];
        DeviceItem *view = self.topViews[index];
        view.status = _status;
    }
}

-(void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    if (selectedIndex<0 && selectedIndex >8) {
        return;
    }
    DeviceItem *view = self.topViews[selectedIndex];
    view.status = QCDeviceTopStatusSelected;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

-(void)cleanNode{
    _password = @"";
    _selectedIndex = -1;
    _status = QCDeviceTopStatusNormal;
    for (DeviceItem *view in _topViews) {
        view.status = QCDeviceTopStatusNormal;
    }
}

@end
