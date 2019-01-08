//
//  HomeViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCollectionViewCell.h"
#import "HomeItemView.h"
#import "HomeTool.h"
#import "HomeCell.h"
#import "MenuLabel.h"
#import "HyPopMenuView.h"
#import "LineLayout.h"
//#import "CustomCollectionViewCell.h"
#import "CircleCollectionViewCell.h"
#import "HomeCircle.h"
#import "PaomaView.h"

static NSString *const cellID = @"custom";

#define Objs @[[MenuLabel CreatelabelIconName:@"icon-l-msg" Title:@"情报交互"],[MenuLabel CreatelabelIconName:@"icon-l-bell" Title:@"预警舆情"],[MenuLabel CreatelabelIconName:@"icon-l-note" Title:@"信息上报"],[MenuLabel CreatelabelIconName:@"icon-l-book" Title:@"推荐阅读"],[MenuLabel CreatelabelIconName:@"icon-l-search" Title:@"舆情搜索"],[MenuLabel CreatelabelIconName:@"icon-l-write" Title:@"信息审核"],[MenuLabel CreatelabelIconName:@"icon-l-star" Title:@"收藏夹"],]

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet HomeItemView *item1;
@property (weak, nonatomic) IBOutlet HomeItemView *item2;
@property (weak, nonatomic) IBOutlet HomeItemView *item3;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *dutyLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *dutyView;
@property (weak, nonatomic) IBOutlet UIView *footVier;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic,strong) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UIView *itemView;
@property (weak, nonatomic) IBOutlet UILabel *adView;
@property (nonatomic, strong) PaomaView *paomaView;
@property (weak, nonatomic) IBOutlet UILabel *adTitleLab;
@property (weak, nonatomic) IBOutlet UIButton *arrupBtn;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic,weak) UIView *menuView;
@property (nonatomic,strong) NSArray *collectionList;
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) NSInteger donwAndUp;
@property (nonatomic,strong) NSMutableArray *itemList;
@property (nonatomic,assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation HomeViewController

#pragma mark 懒加载
-(NSMutableArray *)dataList
{
    if (!_dataList) {
        self.dataList = [[NSMutableArray alloc]init];
    }
    return _dataList;
}

-(NSMutableArray *)itemList
{
    if (!_itemList) {
        NSMutableArray *name = [[NSMutableArray alloc]initWithContentsOfFile:PATH(@"HomeCircle", @"plist")];
        self.itemList = [NSMutableArray arrayWithArray:[HomeCircle objectArrayWithKeyValuesArray:name]];
//        _itemList = [[NSMutableArray alloc] init];
    }
    return _itemList;
}

-(NSArray *)collectionList
{
    if (!_collectionList) {
        NSMutableArray *name = [[NSMutableArray alloc]initWithContentsOfFile:PATH(@"HomeMenu", @"plist")];
        self.collectionList = name;
    }
    return _collectionList;
}

-(UICollectionView *)collectionView {
    
    if (!_collectionView) {
        LineLayout *layout = [[LineLayout alloc]init];
        layout.itemSize = CGSizeMake(160 * Main_Screen_Width / 375.0, 160 * Main_Screen_Width / 375.0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 200) collectionViewLayout:layout];
        _collectionView.decelerationRate = 0.0;
//        _collectionView.decelerating = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
//        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CustomCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellID];
        [_collectionView registerClass:[CircleCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = RGBCOLOR(50, 125, 160);
    }
    return _collectionView;
    
}

#pragma mark 系统方法

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemView.backgroundColor = RGBCOLOR(50, 125, 160);
    _isFirstLoad = YES;
    self.title = @"舆情快递";
    _selectedIndex = 1;
    
    
    [self initData];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self loadCircleData];
//    });
    
    [self setUI];
    
    [self showAD];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadCircleData];
    if (!_isFirstLoad) {
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.alpha = 0;
            self.collectionView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
    _isFirstLoad = NO;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (Main_Screen_Height < 568) {
        self.footVier.ve_y = self.view.ve_height - 35;
        self.topView.ve_height = 140;
        self.itemView.ve_y = 140;
        self.dutyView.ve_y = CGRectGetMaxY(self.topView.frame) + 58;
        self.tableView.ve_y = CGRectGetMaxY(self.dutyView.frame);
    }
    
    _arrupBtn.centerY = (self.view.ve_height - CGRectGetMaxY(self.tableView.frame)) * 0.5;
    [self setupCollectionView];
}

-(void)initData{
    HomeList *list1 = [[HomeList alloc]init];
    list1.title = @"情报交互";
    list1.icon  = @"icon-msg";
    list1.hasNew = YES;
    list1.newsTitle = @"情报交互最新消息";
    
    HomeList *list2 = [[HomeList alloc]init];
    list2.title = @"舆情预警";
    list2.icon  = @"icon-l-bell";
    list2.newsTitle = @"舆情预警最新消息标题舆情预警最新消息标题舆情预警最新消息标题舆情预警最新消息标题舆情预警最新消息标题";
    
    HomeList *list3 = [[HomeList alloc]init];
    list3.title = @"区县上报";
    list3.icon  = @"icon-note";
    list3.newsTitle = @"区县上报最新消息标题";
    
    [self.dataList addObject:list1];
    [self.dataList addObject:list2];
    [self.dataList addObject:list3];
    
}

-(void)setSelectedCircleWithIndex:(NSInteger)index{
//    _selectedIndex = index;
    if (self.itemList.count == 0) {
        return;
    }
    HomeCircle *homeCircle = self.itemList[index];
    _item1.circle = homeCircle.green;
    _item2.circle = homeCircle.yellow;
    _item3.circle = homeCircle.red;
}

#pragma mark - 方法
//设置CollectionView
-(void)setupCollectionView{
    [self.topView addSubview:self.collectionView];
    self.collectionView.ve_height = self.topView.ve_height;
    self.collectionView.contentOffsetX = 160 * Main_Screen_Width / 375.0 -20;
}

//跑马灯
- (PaomaView *)paomaView
{
    if (!_paomaView) {
        NSString *str = @"徐坤, 龙育锐, 王文杰, 龙育锐, 王文杰, 龙育锐, 王文杰, 龙育锐";
        _paomaView = [[PaomaView alloc] initWithFrame:CGRectMake(_adTitleLab.ve_x + _adTitleLab.ve_width, 7, self.view.ve_width - _adTitleLab.ve_x - _adTitleLab.ve_width, _adTitleLab.height) andPaomaText:str];
    }
    return _paomaView;
}

-(void)showAD{
    [_dutyView addSubview:self.paomaView];
}

- (void)paomadeng:(CGRect)rect{
    
    float w = self.view.ve_width;
    if (_adView.ve_width <= w) {
        return;
    }
    
    CGRect frame = _adView.frame;
    frame.origin.x = self.view.x;
//    self.frame = frame;
    
    [UIView beginAnimations:@"textAnimation" context:NULL];
    [UIView setAnimationDuration:8.0f*(w<self.view.ve_width?self.view.ve_width:w) /self.view.ve_width];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];//是否能反转
    [UIView setAnimationRepeatCount:LONG_MAX];//重复次数
    
    frame.origin.x = -w;
    _adView.frame = frame;
    [UIView commitAnimations];
}

//设置UI
-(void)setUI{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    [_tableView setScrollEnabled:NO];
    [_tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(ShowMenu:)];
    swip.delegate = self;
    [swip setDirection:UISwipeGestureRecognizerDirectionUp];
    self.footVier.userInteractionEnabled = YES;
    [self.footVier addGestureRecognizer:swip];
    
    UISwipeGestureRecognizer *swip2 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(ShowMenu:)];
    swip2.delegate = self;
    [swip2 setDirection:UISwipeGestureRecognizerDirectionUp];
    self.tableView.userInteractionEnabled = YES;
    [self.tableView addGestureRecognizer:swip2];
    
}

//跳转视图
-(void)openItemVC:(NSInteger)index{
    VEAppDelegate *appDelegate = (VEAppDelegate *)[UIApplication sharedApplication].delegate;
    self.sideMenuViewController.contentViewController = [appDelegate centerViewControllerAtIndex:index];
    [self.sideMenuViewController hideMenuViewController];
}


-(void)loadCircleData{
    //预警舆情
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [HomeTool loadHomeTypeListWithTypeId:@"2" resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [hud hide:YES afterDelay:0.3];
            self.itemList = [NSMutableArray arrayWithArray:JSON];
            [self.collectionView reloadData];
            
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self setSelectedCircleWithIndex:_selectedIndex];
                    [self rollToCollection:_selectedIndex];
                });

        }else{
            [hud hide:YES afterDelay:0.3];
        }
    }];
}

#pragma mark 监听方法
-(void)longClick:(UILongPressGestureRecognizer *)recognizer
{
    //从视图中得到长按的点的坐标。以self为坐标原点
    CGPoint point = [recognizer locationInView:self.view];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _lastPoint = point;
            if (recognizer.view == _collectionView || recognizer.view == _menuView) {
                _donwAndUp = 1;
            }else{
                _donwAndUp = 0;
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat offestY = _lastPoint.y - point.y;
            _footVier.ve_y +=  - offestY;
            _menuView.ve_y = CGRectGetMaxY(_footVier.frame);
            DLog(@"%lf",offestY);
            
            if (offestY == 0.5) {
                _donwAndUp = 0;
            }else if(offestY == - 0.5){
                _donwAndUp = 1; //向下
            }else if (offestY < - 0.4) {
                _donwAndUp = 1; //向下
            }else{
                _donwAndUp = 0; //向上
            }
            _lastPoint = point;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (_donwAndUp == 1) {
                [UIView animateWithDuration:0.4 animations:^{
                    _footVier.ve_y = self.view.ve_height - _footVier.ve_height;
                    _menuView.ve_y = CGRectGetMaxY(_footVier.frame);
                }];
            }else{
                [UIView animateWithDuration:0.4 animations:^{
                    _footVier.ve_y = -_footVier.ve_height;
                    _menuView.ve_y = CGRectGetMaxY(_footVier.frame);
                }];
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)ShowMenu:(id)sender {
    [HyPopMenuView CreatingPopMenuObjectItmes:Objs TopView:nil /*nil*/OpenOrCloseAudioDictionary:nil /*nil*/ SelectdCompletionBlock:^(MenuLabel *menuLabel, NSInteger index) {
        
        [self openItemVC:index+1];
    }];
}

#pragma mark - UITableView 数据源&代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"HomeCell";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil)
    {
        cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.homeList = self.dataList[indexPath.section * 3 + indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (Main_Screen_Height < 568) {
        return 50;
    }
    return 80 * Main_Screen_Height / 667.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = 1;
    switch (indexPath.row) {
        case 0:
            index = 1;
            break;
        case 1:
            index = 3;
            break;
        case 2:
            index = 2;
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppChangeLeftPanSelIndexNotification object:nil userInfo:@{@"index":[NSString stringWithFormat:@"%ld",index]}];
    
    [self openItemVC:index];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.itemList.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CircleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.homeCircle = self.itemList[indexPath.row];
    __weak __typeof(self)weakSelf = self;
    cell.selectedCircle = ^(NSInteger index){
        [weakSelf setSelectedCircleWithIndex:index];
    };
    return cell;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        int divisor = 0;
        if (Main_Screen_Height == 568) {
            divisor = 116;
        }else if (Main_Screen_Height == 667) {
            divisor = 140;
        }else{
            divisor = 157;
        }
        NSInteger index = scrollView.contentOffset.x / divisor;
        _selectedIndex = index;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        int divisor = 0;
        if (Main_Screen_Height == 568) {
            divisor = 116;
        }else if (Main_Screen_Height == 667) {
            divisor = 140;
        }else{
            divisor = 157;
        }
        NSLog(@"====%.f", scrollView.contentOffset.x);
        NSInteger index = scrollView.contentOffset.x / divisor;
        _selectedIndex = index;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedCircleWithIndex:indexPath.row];
    [self rollToCollection:indexPath.row];
}

-(void)rollToCollection:(NSInteger)index{
    CGFloat X = (160 * Main_Screen_Width / 375.0 -20) * index;
    [self.collectionView setContentOffset:CGPointMake(X, 0) animated:YES];
}



#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

@end

