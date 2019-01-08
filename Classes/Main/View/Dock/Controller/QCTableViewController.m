//
//  QCTableViewController.m
//  Dock
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCTableViewController.h"
#import "ResultTableViewCell.h"

@interface QCTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation QCTableViewController

-(NSMutableArray *)datalist
{
    if (!_datalist) {
        self.datalist = [[NSMutableArray alloc]init];
    }
    return _datalist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化tableView
    [self setupTable];
    
    self.cellHeight = 68;
}

#pragma mark - 初始化
/**
 *  初始化列表
 */
-(void)setupTable
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:RGBCOLOR(246, 246, 246)];
    _tableView.ve_width = Main_Screen_Width;
    _tableView.ve_height = Main_Screen_Height - 66 - 44;
    [self.view addSubview:_tableView];
    
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMsg)];
    [self.tableView.header beginRefreshing];
    
}

-(void)loadMoreData{
}

-(void)loadNewMsg{
}

-(void)showNewCount:(NSString *)msg
{
    UILabel *countLabel = [[UILabel alloc]init];
    countLabel.width = [UIScreen mainScreen].bounds.size.width;
    countLabel.height = 35;
    countLabel.backgroundColor = [UIColor colorWithPatternImage:[QCZipImageTool imageNamed:@"timeline_new_status_background"]];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.font = [UIFont systemFontOfSize:16.0];
    countLabel.y = self.tableView.ve_y - countLabel.height;
    [self.view addSubview:countLabel];
//    [self.view insertSubview:countLabel belowSubview:self.navigationController.navigationBar];
    countLabel.text = msg;
    NSTimeInterval runTime = 0.5;
    [UIView animateWithDuration:runTime animations:^{
        countLabel.transform = CGAffineTransformMakeTranslation(0, countLabel.height);
    } completion:^(BOOL finished) {
        NSTimeInterval delayTime = 1.0;
        [UIView animateWithDuration:runTime
                              delay:delayTime options:UIViewAnimationOptionCurveLinear animations:^{
                                  countLabel.transform = CGAffineTransformIdentity;
                              } completion:^(BOOL finished) {
                                  [countLabel removeFromSuperview];
                              }];
    }];
}

#pragma mark - TableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger count = self.datalist.count;
    
    if (self.datalist.count == 0 || self.noMoreResult) {
        count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.datalist.count == 0){
        ResultTableViewCell *cell = [ResultTableViewCell cellWithTableView:tableView isNoMoreResult:NO];
        return cell;
    }else if (self.noMoreResult && indexPath.section == self.datalist.count){
        ResultTableViewCell *cell = [ResultTableViewCell cellWithTableView:tableView isNoMoreResult:YES];
        return cell;
    }else{
        if (indexPath.section == self.datalist.count - 1 && self.noMoreResult == NO) {
            [self loadMoreData];
        }
        return [self tableView:tableView hasResultCellRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView hasResultCellRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - tableView每个Cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.datalist.count == 0) {
        return 304;
    }else if(self.noMoreResult && indexPath.section == self.datalist.count){
        return 33;
    }
    return self.cellHeight;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
////    Group *group = self.datalist[section];
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
//    lable.font = [UIFont boldSystemFontOfSize:14];
//    lable.text = [NSString stringWithFormat:@"    aaa"];
//    lable.backgroundColor = selectedBackgroundColor;
//    return lable;
//}
@end
