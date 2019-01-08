//
//  MessageVC.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/24.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MessageVC.h"
#import "VECustomAlertTableViewCell.h"
#import "MessageTool.h"
#import "AFNetworking.h"
#import "MessageDetailViewController.h"
@interface MessageVC()

@property (nonatomic,assign) NSInteger countOfNew;

@property (nonatomic,assign) NSInteger newCount;

@end

@implementation MessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellHeight = kCellHeight;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(loadNewMessage) name:kAppDidReceiveRemoteNotification object:nil];
    [self setup];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidReceiveRemoteNotification object:nil];
}

-(void)setup{
    if (self.boxType !=BoxTypeOutput) {
        [self.tableView setEditing:NO];
    }
}

#pragma mark  我的方法

-(void)loadNewMessage{
    [self.tableView.header beginRefreshing];
}

-(void)markAll{
    self.countOfNew = 0;
    
    NSString *articleIds = @"";
    NSString *warnTypes = @"";
    
    for (IntelligenceAgent *intelligAgent in self.datalist){
        if (intelligAgent.isRead == NO){
            intelligAgent.isRead = YES;
            intelligAgent.latestTimeReply = (intelligAgent.newestTimeReply + 2.0);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setValue:[NSNumber numberWithBool:YES] forKey:kIntelligenceIsRead];
            [info setValue:[NSNumber numberWithDouble:intelligAgent.latestTimeReply]  forKey:kIntelligenceLatestTimeReply];
            
            [MessageTool setIntelligenceInfo:info
                                   InBoxType:self.boxType
                               withArticleID:intelligAgent.articleId
                                 andWarnType:intelligAgent.warnType];
        }
        
        if (self.boxType == BoxTypeInput){
            if (intelligAgent.isReadMarkUpload == NO){
                if (intelligAgent.articleId){
                    if (articleIds.length == 0){
                        articleIds = intelligAgent.articleId;
                        warnTypes = [NSString stringWithFormat:@"%ld", (long)intelligAgent.warnType];
                    }else{
                        articleIds = [articleIds stringByAppendingFormat:@",%@", intelligAgent.articleId];
                        warnTypes = [warnTypes stringByAppendingFormat:@",%ld", (long)intelligAgent.warnType];
                    }
                }
            }
        }
    }
    
    
    if (self.boxType == BoxTypeInput)
    {
        [MessageTool markReadWithAid:articleIds resultInfo:^(BOOL success, id JSON) {
            if (success) {
                [self saveUploadReadMarkToLocalDBWithIds:articleIds andWarnTypes:warnTypes];
            }
        }];
    }
    
    [self refreshBox];
    [self.tableView reloadData];
}

//获取数据
-(void)loadNewMsg
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"page"] = @"1";
    parameters[@"limit"] = @"20";
    parameters[@"device"] = @"iga";
    parameters[@"io"] = [NSString stringWithFormat:@"%ld", self.boxType - 1];
    parameters[@"exchangeType"] =[NSString stringWithFormat:@"%ld", self.columnType];

    NSString *lastAid = @"0";
    if (self.datalist.count != 0) {
        IntelligenceAgent *agent = [self.datalist firstObject];
        lastAid = agent.articleId;
    }
   
    
    [MessageTool loadMessageListWithParamters:parameters lastAid:lastAid boxType:self.boxType resultInfo:^(BOOL success, id JSON) {
        if (success) {
            NSArray *list = JSON[@"list"];
            self.countOfNew = [JSON[@"count"] integerValue];
            self.datalist = [NSMutableArray arrayWithArray:list];
            [self isNoMoreResult:list];
            NSInteger count = [JSON[@"newCount"] integerValue];
//            if (count > 0) {
//                [self showNewCount:[NSString stringWithFormat:@"您有%ld条新消息",count]];
//            }else{
//                [self showNewCount:@"没有新的消息，请稍后再试"];
//            }
        }
        [self refreshBox];
        [self.tableView.header endRefreshing];
        [self.tableView reloadData];
    }];
}

-(void)loadMoreData{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"page"] = [NSString stringWithFormat:@"%ld",self.datalist.count / kBatchSize + 1];
    parameters[@"limit"] = @"20";
    parameters[@"device"] = @"iga";
    parameters[@"io"] = [NSString stringWithFormat:@"%ld", self.boxType - 1];
    parameters[@"exchangeType"] =[NSString stringWithFormat:@"%ld", self.columnType];
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:@""];
    [MessageTool loadMessageListWithParamters:parameters lastAid:@"0" boxType:self.boxType resultInfo:^(BOOL success, id JSON) {
        if (success) {
            NSArray *list = JSON[@"list"];
            self.countOfNew += [JSON[@"count"] integerValue];
            [self.datalist addObjectsFromArray:list];
            [self isNoMoreResult:list];
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@""];
        }else{
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@"数据加载失败"];
        }
        [self refreshNewBox];
        [self.tableView.header endRefreshing];
        [self.tableView reloadData];
    }];
}

-(void)isNoMoreResult:(NSArray *)array{
    if(array.count == kBatchSize){
        self.noMoreResult = NO;
    }else{
        self.noMoreResult = YES;
    }
}

-(void)refreshBox{
    if (self.refreshNewBox) {
        self.refreshNewBox(self.boxType,self.countOfNew);
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView hasResultCellRowAtIndexPath:(NSIndexPath *)indexPath{
    VECustomAlertTableViewCell *cell = [VECustomAlertTableViewCell cellWithTableView:tableView];
    IntelligenceAgent *agent = self.datalist[indexPath.section];
    if (self.boxType == BoxTypeOutput) {
        agent.isRead = NO;
    }
    cell.agent = agent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    if (self.datalist.count == 0) {
        return;
    }
    
    MessageDetailViewController *detailViewController = [[MessageDetailViewController alloc]initWithNibName:@"MessageDetailViewController" bundle:nil];
    IntelligenceAgent *agent = self.datalist[indexPath.section];
    detailViewController.intelligAgent = agent;
    detailViewController.boxType = self.boxType;
    detailViewController.columnType = self.columnType;
    detailViewController.deleteItem = ^(NSInteger index){
        [self.datalist removeObjectAtIndex:index];
        [self.tableView reloadData];
    };
    if (self.selectedRow) {
        self.selectedRow(detailViewController);
    }
    
    //标记已读
    if (agent.isRead == NO) {
        agent.isRead = YES;
        self.countOfNew--;
        
        agent.isRead = YES;
        agent.latestTimeReply = (agent.newestTimeReply + 1.0);
        agent.localTimeReply = agent.latestTimeReply;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSNumber numberWithBool:YES] forKey:kIntelligenceIsRead];
        [info setValue:[NSNumber numberWithDouble:agent.latestTimeReply]  forKey:kIntelligenceLatestTimeReply];
        
        // 更新最新的回复时间到数据库
        [MessageTool setIntelligenceInfo:info
                               InBoxType:self.boxType
                           withArticleID:agent.articleId
                             andWarnType:agent.warnType];
        
        if (self.boxType == BoxTypeInput) {
            [MessageTool markReadWithAid:agent.articleId resultInfo:^(BOOL success, id JSON) {
                if (success) {
                    [self saveUploadReadMarkToLocalDBWithIds:agent.articleId andWarnTypes:[NSString stringWithFormat:@"%ld", (long)agent.warnType]];
                }
            }];
        }
        [self refreshBox];
        [self.tableView reloadData];
    }
    
}

-(void)saveUploadReadMarkToLocalDBWithIds:(NSString *)articleIDs andWarnTypes:(NSString *)warnTypes {
    NSArray *articleIdsList = [articleIDs componentsSeparatedByString:@","];
    NSArray *warnTypesList  = [warnTypes componentsSeparatedByString:@","];
    NSInteger index = 0;
    NSInteger warnType = 0;
    for (NSString *articleId in articleIdsList){
        if (index < warnTypesList.count){
            warnType = [[warnTypesList objectAtIndex:index] integerValue];
        }
        ++index;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSNumber numberWithBool:YES] forKey:kIntelligenceIsReadMarkUpload];
        [MessageTool setIntelligenceInfo:info
                               InBoxType:BoxTypeInput
                           withArticleID:articleId
                             andWarnType:warnType];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bkView = [[UIView alloc] init];
    bkView.backgroundColor =  selectedBackgroundColor;
    return bkView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.boxType == BoxTypeOutput){

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            IntelligenceAgent *agent = self.datalist[indexPath.section];
            MBProgressHUD *hud=[MBProgressHUD showMessage:@"正在删除，请稍后..."];
            [MessageTool deleteMessageWithAid:agent.articleId resultInfo:^(BOOL success, id JSON) {
               if (success) {
                   [MBProgressHUD changeToSuccessWithHUD:hud Message:@"删除成功"];
                   if (agent.isRead == NO)
                   {
                       --self.countOfNew;
                       [self refreshBox];
                   }
                   [self.datalist removeObjectAtIndex:indexPath.section];
               }else{
                   [MBProgressHUD changeToErrorWithHUD:hud Message:@"删除失败，请重新删除"];
               }
               [self.tableView reloadData];
            }];
        }];
        NSArray *array = @[action,action2];
        [UIAlertController showAlertWithtitle:@"提示" message:@"是否删除此条信息" target:self alertActions:array];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.boxType !=BoxTypeOutput) {
        return NO;
    }else{
        if (self.datalist.count == 0) {
            return NO;
        }else if (self.datalist.count == indexPath.section && self.noMoreResult == YES){
            return NO;
        }else{
            return YES;
        }
    }
}

@end
