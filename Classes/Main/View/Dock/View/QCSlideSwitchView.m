//
//  QCSlideSwitchView.m
//  Dock
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCSlideSwitchView.h"
#import "UIScrollView+Dock.h"
#import "QCScrollView.h"
@interface QCSlideSwitchView()<UIScrollViewDelegate,QCDockDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) QCDock *dock;

@property (nonatomic, strong) NSArray *itemList;

@end

@implementation QCSlideSwitchView

-(instancetype)initWithFrame:(CGRect)frame itemList:(NSArray *(^)())itemList
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemList = itemList();
        //设置菜单
        [self setup];
        
        [self buildUI];
    }
    return self;
}

//设置菜单
-(void)setup
{
    //设置
    QCDock *dock = [[QCDock alloc]init];
    dock.delegate = self;
    [self addSubview:dock];
    _dock = dock;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    QCScrollView *scrollView = [[QCScrollView alloc]init];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.itemList.count * Main_Screen_Width , 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.delaysContentTouches = NO;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
}

#pragma mark 我的方法
- (void)buildUI
{
    //代理返回个数
    NSUInteger number = self.itemList.count;
    for (int i=0; i<number; i++) {
        UIViewController *vc = self.itemList[i];
        //把UIViewController中的View添加到UIScrollView中
        [_scrollView addSubview:vc.view];
        //添加dock的item
        [_dock addItemWithTitle:vc.title index:i];
    }
}

-(void)hideBoxImageView:(BOOL)hidden index:(NSInteger)index{
    [_dock hideBoxImageView:hidden index:index];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = Main_Screen_Width;
    
    _dock.ve_width = width;
    _dock.ve_height = 44;
    
    _scrollView.ve_width = width;
    _scrollView.ve_height = HEIGHT(self) - MaxY(_dock);
    _scrollView.ve_x = 0;
    _scrollView.ve_y = MaxY(_dock);
    NSUInteger count = _scrollView.subviews.count;
    for (int i = 0; i<count; i++) {
        UIView *view = _scrollView.subviews[i];
        view.ve_x = Main_Screen_Width * i;
        view.ve_y = 0;
        view.ve_width = Main_Screen_Width;
        view.ve_height = _scrollView.ve_height;
    }
}

#pragma mark 代理
/**
 *  滚动结束
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    double page = scrollView.contentOffset.x / WIDTH(scrollView);
    NSInteger currentPage = (int)(page + 0.5 );
    
    [_dock setSelectIndex:currentPage];
}
/**
 *  选项卡被点击，切换视图
 *
 *  @param selectIndex 点击选项卡的标记
 */
-(void)dockItemClick:(QCDock *)dockItem selectIndex:(NSInteger)selectIndex
{
    //切换选中
    [_dock setSelectIndex:selectIndex];
    
    //切换视图
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint contentOffset = _scrollView.contentOffset;
        contentOffset.x = selectIndex * _scrollView.frame.size.width;
        [_scrollView setContentOffset:contentOffset];
    }];
    
    if (self.selectIndex) {
        self.selectIndex(selectIndex);
    }
}

-(void)selectItem:(NSInteger)index{
    //切换选中
    [_dock setSelectIndex:index];
    
    //切换视图
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint contentOffset = _scrollView.contentOffset;
        contentOffset.x = index * _scrollView.frame.size.width;
        [_scrollView setContentOffset:contentOffset];
    }];
    
    if (self.selectIndex) {
        self.selectIndex(index);
    }
}

@end
