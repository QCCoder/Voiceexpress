//
//  VEGroupListViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEGroupListViewController.h"
#import "QCSlideSwitchView.h"
#import "GroupListTableVC.h"
#import "GroupTool.h"
#import "UIBarButtonItem+Extension.h"
#import "VEGroupManagerViewController.h"
@interface VEGroupListViewController ()

@property (nonatomic,strong) NSMutableArray *itemlist;

@property (nonatomic,weak) QCSlideSwitchView *slideView;

@property (nonatomic,assign) NSInteger selectIndex;

@property (nonatomic,strong) GroupList *datalist;



@end

@implementation VEGroupListViewController

-(NSMutableArray *)itemlist
{
    if (!_itemlist) {
        self.itemlist = [NSMutableArray array];
    }
    return _itemlist;
}

-(NSMutableArray *)selectedList
{
    if (!_selectedList) {
        self.selectedList = [NSMutableArray array];
    }
    return _selectedList;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setup];
    [self setupNav];
    [self loadGroupList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"GroupList Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"GroupList Disappear");
}

-(void)loadGroupList{
    
    [MBProgressHUD showMessage:@"" toView:self.view];
    [GroupTool loadGroupListWith:^(BOOL success, id JSON) {
        [MBProgressHUD hideHUDForView:self.view];
        self.datalist = JSON;
        
        for (int i = 0; i<self.itemlist.count ; i++) {
            GroupListTableVC *vc = self.itemlist[i];
            if (i == 0) {
                vc.datalist = [NSMutableArray arrayWithArray:self.datalist.allUsersList];
                [vc setSelectedData:_selectedList];
            }else if (i == 1){
                vc.datalist = [NSMutableArray arrayWithArray:self.datalist.commonContactsList];
                [vc setSelectedData:_selectedList];
            }else{
                vc.datalist = [NSMutableArray arrayWithArray:self.datalist.customGroupList];
                [vc setSelectedData:_selectedList];
            }
        }
    }];
}

/**
 *  初始化标题
 */
-(void)setup
{
    _datalist = [[GroupList alloc]init];
    
    //添加tableView
    [self addTableWithTitle:self.config[AllGruop] boxType:GroupTypeAll];
    [self addTableWithTitle:self.config[FastGroup] boxType:GroupTypeContacts];
    [self addTableWithTitle:self.config[CustomGroup] boxType:GroupTypeCustom];

    //初始化内容
    QCSlideSwitchView *slideView= [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, self.view.ve_width, Main_Screen_Height) itemList:^NSArray *{
        return self.itemlist;
    }];
    slideView.scrollView.scroll = YES;
    slideView.selectIndex = ^(NSInteger selectIndex){
        self.selectIndex = selectIndex;
    };
    [self.view addSubview:slideView];
    _slideView = slideView;
    //必要
    [_slideView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self.navigationController screenEdgePanGestureRecognizer]];
}

-(void)goback{
    if (self.selectedContacts && self.selectedList.count !=0) {
        self.selectedContacts(self.selectedList);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupNav{
    [self setTitle:self.config[SelectPersion]];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goback) image:@"tab_icon_back" highImage:nil];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(goGroupManager) image:self.config[Icon_Group] highImage:nil];
}

//添加tableView
-(void)addTableWithTitle:(NSString *)title boxType:(GroupType)boxType;
{
    GroupListTableVC *vc = [[GroupListTableVC alloc]init];
    [vc setTitle:title];
    vc.favorite = ^(GroupType groupType,GroupMember *groupMember){
        if (groupType == GroupTypeContacts) {
            GroupListTableVC *vc = self.itemlist[0];
            [vc setContactMember:groupMember];
        }else{
            GroupListTableVC *vc = self.itemlist[1];
            [vc setContactMember:groupMember];
        }
    };
    vc.getSelectedList = ^(GroupType groupType,NSMutableArray *array){
        self.selectedList = array;
        if (groupType == GroupTypeAll) {
            GroupListTableVC *vc1 = self.itemlist[1];
            [vc1 setSelectedData:array];
            
            GroupListTableVC *vc2 = self.itemlist[2];
            [vc2 setSelectedData:array];
        }else if(groupType == GroupTypeContacts){
            GroupListTableVC *vc = self.itemlist[0];
            [vc setSelectedData:array];
            
            GroupListTableVC *vc2 = self.itemlist[2];
            [vc2 setSelectedData:array];
        }else{
            
            GroupListTableVC *vc = self.itemlist[0];
            [vc setSelectedData:array];
            
            GroupListTableVC *vc1 = self.itemlist[1];
            [vc1 setSelectedData:array];
        }
    };
    
    vc.groupType = boxType;
    [self.itemlist addObject:vc];
}

-(void)goGroupManager{
    VEGroupManagerViewController *vc = [[VEGroupManagerViewController alloc]init];
    vc.customGroupList = [NSMutableArray arrayWithArray:self.datalist.customGroupList];
    vc.getCustomGropList = ^(NSMutableArray *customGroupList){
        self.datalist.customGroupList = customGroupList;
        GroupListTableVC *vc = self.itemlist[2];
        vc.datalist = customGroupList;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSArray *)getAllUser{
    return self.datalist.allUsersList;
}

@end
