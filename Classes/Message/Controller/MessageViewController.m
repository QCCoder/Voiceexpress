//
//  MessageViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/24.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MessageViewController.h"
#import "QCSlideSwitchView.h"
#import "MessageVC.h"
#import "UIAlertController+Extend.h"
#import "VEMessageDistributeViewController.h"
@interface MessageViewController ()

@property (nonatomic,strong) NSMutableArray *itemlist;

@property (nonatomic,weak) QCSlideSwitchView *slideView;

@property (nonatomic,assign) NSInteger selectIndex;

@end

@implementation MessageViewController

-(NSMutableArray *)itemlist
{
    if (!_itemlist) {
        self.itemlist = [NSMutableArray array];
    }
    return _itemlist;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    
    [self setupNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"MessageList Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"MessageList Disappear");
}

/**
 *  初始化标题
 */
-(void)setup
{
    //添加tableView
    [self addTableWithTitle:self.config[ToMe] boxType:BoxTypeInput];
    [self addTableWithTitle:self.config[SenderTo] boxType:BoxTypeOutput];
    
    if (![UserTool user].isTopLeader) {
        [self addTableWithTitle:self.config[RelativeMe] boxType:BoxTypeRelativeMe];
    }
    
    //初始化内容
    QCSlideSwitchView *slideView= [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, self.view.ve_width, Main_Screen_Height) itemList:^NSArray *{
        return self.itemlist;
    }];
    slideView.selectIndex = ^(NSInteger selectIndex){
        self.selectIndex = selectIndex;
    };
    [self.view addSubview:slideView];
    _slideView = slideView;
    //必要
    [_slideView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self.navigationController screenEdgePanGestureRecognizer]];
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    NSMutableArray *array = [NSMutableArray array];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(showList) image:Config(Tab_Icon_More) highImage:nil];
    [array addObject:more];
    UIBarButtonItem *send =[UIBarButtonItem itemWithTarget:self action:@selector(distributeAlertBtnTapped) image:Config(Icon_Write) highImage:nil];
    [array addObject:send];
    self.navigationItem.rightBarButtonItems = array;
    
}

-(void)showList{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[UIAlertAction actionWithTitle:self.config[Cancle] style:UIAlertActionStyleCancel handler:nil]];
    [array addObject:[UIAlertAction actionWithTitle:self.config[RefreshAllData] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (MessageVC *vc in self.itemlist) {
            [vc loadNewMessage];
        }
    }]];
    
    [array addObject:[UIAlertAction actionWithTitle:self.config[MarkToRead] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MessageVC *vc = self.itemlist[self.selectIndex];
        [vc markAll];
    }]];
    
    [UIAlertController showActionSheetWithtitle:nil message:nil target:self alertActions:array];
}

-(void)distributeAlertBtnTapped{
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc] initWithNibName:@"VEMessageDistributeViewController" bundle:nil];
    distributeViewController.columnType = self.columnType;
    distributeViewController.sendType = SendTypeNewIntelligence;
    distributeViewController.sendSuccess = ^(){
        [self.slideView selectItem:1];
        MessageVC *vc = self.itemlist[1];
        [vc.tableView.header beginRefreshing];
    };
    
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

//添加tableView
-(void)addTableWithTitle:(NSString *)title boxType:(BoxType)boxType;
{
    MessageVC *vc = [[MessageVC alloc]init];
    [vc setTitle:title];
    vc.boxType = boxType;
    vc.columnType = self.columnType;
    vc.refreshNewBox = ^(BoxType boxType,NSInteger countOfNew){
        BOOL isShow = NO;
        if (countOfNew <= 0) {
            isShow = YES;
        }
        [_slideView hideBoxImageView:isShow index:boxType - 1];
    };
    vc.selectedRow = ^(UIViewController *vc){
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.itemlist addObject:vc];
}
@end
