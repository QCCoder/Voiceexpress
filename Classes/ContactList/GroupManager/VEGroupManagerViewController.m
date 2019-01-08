//
//  VEGroupManagerViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-18.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEGroupManagerViewController.h"
#import "VETableViewCell.h"
#import "VEAddGroupViewController.h"
#import "VECustomGroupDetailViewController.h"
#import "GroupTool.h"

@interface VEGroupManagerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic,strong) NSDictionary *sort;
@end

@implementation VEGroupManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sort = [self getGroupIds];
    
    [self setupNav];
    
    [self setupTableView];
}

-(void)setupTableView{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    longPress.minimumPressDuration = 0.3;
    [self.tableView addGestureRecognizer:longPress];
    // 去掉多余的分割线
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

-(void)setupNav{
    self.promptView.layer.cornerRadius = 5.0;
    [self setTitle:self.config[GroupManner]];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(addNewGroup) image:self.config[Icon_Add] highImage:nil];
     self.navigationItem.leftBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(goback) image:self.config[Tab_Icon_Back] highImage:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"GroupManager Appear");
    if (self.customGroupList.count == 2 &&
        [VEUtility shouldShowSortableTipView])
    {
        [self addSortableTipView];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"GroupManager Disappear");
}

#pragma mark - IBAction
-(void)goback{
    if (self.getCustomGropList) {
        self.getCustomGropList(self.customGroupList);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)addNewGroup
{
    VEAddGroupViewController *addGroupVC = [[VEAddGroupViewController alloc] initWithNibName:@"VEAddGroupViewController" bundle:nil];
    addGroupVC.customGroupList = self.customGroupList;
    addGroupVC.addGroupList = ^(NSMutableArray *customGroupList){
        self.customGroupList = customGroupList;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:addGroupVC animated:YES];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gesture
{
    if (self.customGroupList.count == 0){
        return; // for show no result
    }
    
    UIGestureRecognizerState state = gesture.state;
    
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state){
        case UIGestureRecognizerStateBegan:{
            if (indexPath){
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 1.0;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath])
            {
                // ... update data source.
                [self.customGroupList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default:{
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                sourceIndexPath = nil;
                cell.hidden = NO;
                snapshot.hidden = YES;
                [snapshot removeFromSuperview];
                snapshot = nil;
                [self uploadChangeSort];
            }];
            break;
        }
    }
}

-(NSDictionary *)getGroupIds{
    NSString *customGroupIds =@"";
    NSString *showOrders =@"";
    for (int i = 0; i< self.customGroupList.count; i++) {
        Group *groupAgent = self.customGroupList[i];
        showOrders = [showOrders stringByAppendingString:[NSString stringWithFormat:@"%d,",i]];
        customGroupIds = [customGroupIds stringByAppendingString:[NSString stringWithFormat:@"%ld,",(long)groupAgent.groupId]];
    }
    
    return @{
             @"showOrders":showOrders,
             @"customGroupIds":customGroupIds
             };
}

-(void)uploadChangeSort{
    NSDictionary *newSort = [self getGroupIds];
    if ([_sort[@"customGroupIds"] isEqualToString:newSort[@"customGroupIds"]]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"正在修改组排序,请稍等.."];
    __weak typeof(self) weakSelf = self;
    [GroupTool sortGroupListWith:newSort resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@"修改排序成功"];
            weakSelf.sort = newSort;
        }else{
            [hud hide:YES];
        }
    }];
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView
{
    UIView *snapshot = nil;
    
    NSArray *cellNib            = [[NSBundle mainBundle] loadNibNamed:@"VETableViewCell" owner:self options:nil];
    VETableViewCell *cell       = [cellNib objectAtIndex:VETableViewCellCustomGroupIndex];
    UILabel *cellLableTitle     = (UILabel *)[cell viewWithTag:kCellTitleTag];
    UILabel *fromCellLableTitle = (UILabel *)[inputView viewWithTag:kCellTitleTag];
    cellLableTitle.text         = fromCellLableTitle.text;
    
    snapshot = cell;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
    snapshot.layer.shadowRadius = 2.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - My Methods

- (void)addSortableTipView
{
    //  最底层的View
    UIView *backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"group_tips"]];
    CGRect rect = imgView.frame;
    rect.origin.x = 162.5f;
    rect.origin.y = 68;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        rect.origin.y -= 20;
    }
    imgView.frame = rect;
    
    [backgroundView addSubview:imgView];
    
    UILongPressGestureRecognizer *longPressGesturer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(removeSortableTipView:)];
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSortableTipView:)];
    
    [backgroundView addGestureRecognizer:longPressGesturer];
    [backgroundView addGestureRecognizer:tapGesturer];

    [self.view addSubview:backgroundView];
}

- (void)removeSortableTipView:(UIGestureRecognizer *)gesturer
{
    [gesturer.view removeFromSuperview];
    [VEUtility setShowSortableTipView:NO];
}

- (void)startShowPromptViewWithTip:(NSString *)tip
{
    self.promptView.alpha = 0;
    self.labelTip.text = tip;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPromptView
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.lableTip.text = nil;
                     }
     ];
}

- (void)openCustomGroupDetailAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.customGroupList.count)
    {
        VECustomGroupDetailViewController *detailVC = [[VECustomGroupDetailViewController alloc] initWithNibName:@"VECustomGroupDetailViewController" bundle:nil];
        detailVC.singleGroupAgent = [self.customGroupList objectAtIndex:index];
        detailVC.addGroupList = ^(Group *singleGroupAgent){
            self.customGroupList[index] = singleGroupAgent;
        };
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)deleteGroupWithTag:(NSInteger)tag
{
    NSString *message = nil;
    if (tag >= 0 && tag < self.customGroupList.count){
        message = ((Group *)self.customGroupList[tag]).groupName;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"是否删除组:%@", message] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteCustomGroupAtIndex:tag];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteCustomGroupAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.customGroupList.count){
        Group *groupAgent = [self.customGroupList objectAtIndex:index];
        MBProgressHUD *hud = [MBProgressHUD showMessage:[NSString stringWithFormat:@"正在删除分组:%@", groupAgent.groupName]];
        [GroupTool deleteGroupWithGroupId:[NSString stringWithFormat:@"%ld",groupAgent.groupId] resultInfo:^(BOOL success, id JSON) {
            if (success) {
                [MBProgressHUD changeToSuccessWithHUD:hud Message:@"删除成功"];
                [self updateCustomGroupListAtIndex:index];
            }else{
                [hud hide:YES];
            }
        }];
    }
   
}
- (void)updateCustomGroupListAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.customGroupList.count)
    {
        [self.customGroupList removeObjectAtIndex:index];
        [self.tableView reloadData];
    }
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.customGroupList.count == 0){
        return 1; // for show no result
    }
    return self.customGroupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.customGroupList.count == 0){
        UITableViewCell * cell = [VEUtility cellForShowNoResultTableView:tableView
                                                             fillMainTip:@"点击右上角新增分组"
                                                           fillDetailTip:nil
                                                         backgroundColor:selectedBackgroundColor];
        return cell;
    }
    
    VETableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CellCustomGroup"];
    if (cell == nil){
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:@"VETableViewCell" owner:self options:nil];
        cell = [cellNib objectAtIndex:VETableViewCellCustomGroupIndex];
    }
    
    cell.deleteGroupItem = ^(){
        [self deleteGroupWithTag:indexPath.row];
    };
    Group *group = self.customGroupList[indexPath.row];
    cell.group = group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.customGroupList.count == 0){
        return;
    }
    
    [self openCustomGroupDetailAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.customGroupList.count == 0){
        return 200;
    }
    return 40;
}

@end
