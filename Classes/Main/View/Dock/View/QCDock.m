//
//  Dock.m
//  GonganNew
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCDock.h"

@interface QCDock ()

//按钮内容
@property (nonatomic,weak) UIView *contentView;

//线条
@property (nonatomic,weak) UIView *line;

@property (nonatomic,strong) NSMutableArray *docks;

@end

@implementation QCDock

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RGBCOLOR(210, 212, 220)];
        _docks = [NSMutableArray array];
        _selectIndex = 1;
        UIView *contentView = [[UIView alloc]init];
        [contentView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:contentView];
        _contentView =contentView;
        
        UIView *line = [[UIView alloc]init];
        [line setBackgroundColor:[UIColor colorWithHexString:Config(MainColor)]];
        [self addSubview:line];
        _line =line;
        
        }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSUInteger count = self.contentView.subviews.count;
    CGFloat width = Main_Screen_Width;
    CGFloat height = self.frame.size.height;
    CGFloat lineH = 2;
    CGFloat lineW = width / count;
    CGFloat itemW = lineW;
    
    [_line setFrame:CGRectMake(0, height - lineH, lineW , 2)];

    CGFloat contentH = self.line.frame.origin.y;
    [_contentView setFrame:CGRectMake(0, 0, width, self.line.frame.origin.y)];
    
    for (int i =0; i <count; i++) {
        if ([self.contentView.subviews[i] isKindOfClass:[UIButton class] ]) {
            UIButton *item = self.contentView.subviews[i];
            item.ve_x = i * itemW;
            item.ve_width = itemW;
            item.ve_height = contentH;
        }else{
            UIView *line = self.contentView.subviews[i];
            line.ve_centerY = contentH * 0.5;
            line.ve_x = (i+1) * itemW;
        }
        
    }
}

// 添加一个菜单选项
- (void)addItemWithTitle:(NSString *)title index:(NSInteger)index
{
    QCDockItem *dockItem = [[QCDockItem alloc]init];
    [dockItem setTag:index];
    [dockItem setTitle:title forState:UIControlStateNormal];
    [dockItem addTarget:self action:@selector(dockItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [dockItem.boxImageView setHidden:YES];
    [self.contentView addSubview:dockItem];
    [_docks addObject:dockItem];
}

//按钮点击返回代理
-(void)dockItemClick:(QCDockItem *)btn
{
    if ([self.delegate respondsToSelector:@selector(dockItemClick:selectIndex:)]) {
        [self.delegate dockItemClick:self selectIndex:btn.tag];
    }
}

//选中的按钮变化，动画
-(void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;    
    [UIView animateWithDuration:0.25 animations:^{
        _line.ve_x = selectIndex * _line.ve_width;
    }];
}

-(void)hideBoxImageView:(BOOL)hidden index:(NSInteger)index{
    QCDockItem *item = _docks[index];
    item.boxImageView.hidden = hidden;
}
@end
