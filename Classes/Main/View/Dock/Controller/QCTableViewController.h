//
//  QCTableViewController.h
//  Dock
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QCTableViewController : UIViewController

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *datalist;//数据源
@property (nonatomic,assign) BOOL isFinsh;//是否完成数据加载
@property (nonatomic,assign) BOOL noMoreResult;
@property (nonatomic,strong) NSMutableDictionary *paramters;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,assign) CGFloat cellHeight;

/**
 *  表格数据源方法,有数据显示
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView hasResultCellRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - TableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;


-(void)loadMoreData;

-(void)loadNewMsg;

-(void)showNewCount:(NSString *)msg;
@end
