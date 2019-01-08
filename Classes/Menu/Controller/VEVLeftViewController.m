//
//  VEVLeftViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-8-21.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEVLeftViewController.h"
#import "RESideMenu.h"
#import "VEAppDelegate.h"
#import "MenuTableViewCell.h"
#import "VEMobileTokenViewController.h"

extern BOOL g_IsMessageOnRed;
extern BOOL g_IsLatestAlertOnRed;
extern BOOL g_IsRecommendReadOnRed;
extern BOOL g_IsInternetAlertOnRed;
extern BOOL g_IsInformReviewOnRed;


@interface VEVLeftViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *line;

@property (strong, nonatomic) IBOutlet UILabel *labelMain;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewLog;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (nonatomic, assign) NSInteger currentSelIndex;
@property (nonatomic,strong) NSArray *dataList;

@end

@implementation VEVLeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(changeLeftPanSelIndex:)
                       name:kAppChangeLeftPanSelIndexNotification
                     object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver];
    [self reloadImage];
    
    VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.launchFromWarnRemoteNotification){
        self.currentSelIndex = 2;
    }else if (appDelegate.launchFromRecommendReadRemoteNotification){
        self.currentSelIndex = 3;
    }else{
        self.currentSelIndex = 0;
    }
    
    // 去掉多余的分割线
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    [self.tableView setTableHeaderView:view];
    self.tableView.scrollsToTop = NO;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshNewFlag)
                   name:kNewFlagChangedNotification
                 object:nil];
    
    self.labelMain.text = [VEUtility currentUserName];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[VEUtility currentIsopenToken] integerValue]== 1) {
        _tokenBtn.hidden = NO;
    }else{
        _tokenBtn.hidden = YES;
    }
    _tokenBtn.hidden = NO;
    DLog(@"Menu Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"Menu Disappear");
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _settingBtn.ve_x = Main_Screen_Width * 0.65 - 14 ;
    self.tableView.ve_width = Main_Screen_Width * 0.9;
    _line.ve_height = 0.3;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}



/**
 *  重新加载资源
 */
-(void)reloadImage{
    [super reloadImage];
    [self getDateList];
    _tokenBtn.imageView.ve_size = CGSizeMake(19, 19);
    _tokenBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [_tokenBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_tokenBtn setImage:Image(Menu_Icon_Key) forState:UIControlStateNormal];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:self.config[Menu_Cell_Normal_Color]]];
    _footView.backgroundColor = [UIColor colorWithHexString:self.config[Menu_Cell_Normal_Color]];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:self.config[Menu_Cell_Normal_Color]]];
    self.imageViewLog.image = [QCZipImageTool imageNamed:self.config[Menu_Icon_User]];
    [self.tokenBtn setImage:[QCZipImageTool imageNamed:self.config[Menu_Icon_Key]] forState:UIControlStateNormal];
    [_settingBtn setImage:Image(Menu_Icon_Setting) forState:UIControlStateNormal];
}

-(void)getDateList{
    NSArray *list = [Menu objectArrayWithKeyValuesArray:[[NSMutableArray alloc]initWithContentsOfFile:[QCZipImageTool getPath:@"Menu.plist"]]];
    NSMutableArray *dataList = [NSMutableArray array];
    if (self.user.isTopLeader) {
        [dataList addObject:list[0]];
        [dataList addObject:[list lastObject]];
        if (self.user.networkReportReview) {
            [dataList insertObject:list[5] atIndex:1];
        }
    }else{
        [dataList addObjectsFromArray:list];
        if (!self.user.networkReportReview) {
            [dataList removeObjectAtIndex:5];
        }
    }
    self.dataList = dataList;
    [self.tableView reloadData];
}

#pragma mark - 事件监听
- (IBAction)gotoMobileToken:(id)sender {
    VEAppDelegate *appDelegate = (VEAppDelegate *)[UIApplication sharedApplication].delegate;
    self.sideMenuViewController.contentViewController = [appDelegate centerViewControllerAtIndex:10];
    [self.sideMenuViewController hideMenuViewController];
}
- (IBAction)showSettingVC:(id)sender {
    [self openItemVC:self.dataList.count];
}

- (void)setCurrentRowSelected
{
    [self.tableView reloadData];
}

- (BOOL)isOnRedAtIndex:(NSInteger)index{
    BOOL isOnRed = NO;
    if (self.user.isTopLeader){
        switch (index){
            case 0:
                isOnRed = g_IsMessageOnRed;
                break;
                
            case 1:
                isOnRed = (self.user.networkReportReview ? g_IsInformReviewOnRed : isOnRed);
                break;
                
            default:
                break;
        }
    }else{
        switch (index){
            case 0:
                isOnRed = g_IsMessageOnRed;
                break;
                
            case 1:
                isOnRed = g_IsInternetAlertOnRed;
                break;
                
            case 2:
                isOnRed = g_IsLatestAlertOnRed;
                break;
                
            case 3:
                isOnRed = g_IsRecommendReadOnRed;
                break;
                
            case 5:
                isOnRed = (self.user.networkReportReview ? g_IsInformReviewOnRed : isOnRed);
                break;
                
            default:
                break;
        }
    }
    return isOnRed;
}

#pragma mark - TableView代理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MenuTableViewCell *cell = [MenuTableViewCell cellWithTableView:tableView];
    cell.imageNew.ve_x = Main_Screen_Width * 0.65;
    Menu *menu = self.dataList[indexPath.row];
    if ([self isOnRedAtIndex:indexPath.row]){
        menu.hasNew = YES;
    }else{
        menu.hasNew = NO;
    }
    if (indexPath.row == self.currentSelIndex){
        menu.isSelected = YES;
    }else{
        menu.isSelected = NO;
    }
    cell.menu = menu;
    
    if (indexPath.row == self.dataList.count - 1) {
        cell.line.hidden = YES;
    }
    
    return cell;
} 

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentSelIndex = indexPath.row;
    
    [self openItemVC:self.currentSelIndex];

    [self setCurrentRowSelected];
}

-(void)openItemVC:(NSInteger)index{
    VEAppDelegate *appDelegate = (VEAppDelegate *)[UIApplication sharedApplication].delegate;
    self.sideMenuViewController.contentViewController = [appDelegate centerViewControllerAtIndex:index];
    [self.sideMenuViewController hideMenuViewController];
}
#pragma mark - 通知

- (void)refreshNewFlag
{
    [self setCurrentRowSelected];
}

- (void)changeLeftPanSelIndex:(NSNotification *)notif
{
    self.currentSelIndex = [[notif.userInfo valueForKey:@"index"] integerValue];
    [self setCurrentRowSelected];
}

@end


