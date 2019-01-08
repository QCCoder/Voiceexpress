//
//  VECustomGroupDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VECustomGroupDetailViewController.h"
#import "VEAddGroupMembersViewController.h"
#import "VETableViewCell.h"

@interface VECustomGroupDetailViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView               *tableView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic, strong) UITextField *textFiledGroupName;

@end

@implementation VECustomGroupDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.promptView.layer.cornerRadius = 5.0;
    self.title = self.singleGroupAgent.groupName;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goback) image:Config(Tab_Icon_Back) highImage:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"GroupDetail Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"GroupDetail Disappear");
}

- (void)goback{
    [self dismissKeyBorad];
    NSString *mayChangedGroupName = self.textFiledGroupName.text;
    if ([mayChangedGroupName isEqualToString:self.title]){
        if (self.addGroupList) {
            self.addGroupList(self.singleGroupAgent);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSInteger length = mayChangedGroupName.length;
        if (length >= 2 && length <= 10){
            [self changeToGroupName:mayChangedGroupName];
        }else{
            NSString *message = (length < 2 ? @"组名称至少2个字" : @"组名称至多10个字");
            ALERT(nil, message);
        }
    }
}

#pragma mark - My Methods

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


- (void)addMemberBtnTapped:(UIButton *)sender
{
    [self dismissKeyBorad];
    [self addMembers];
}

- (void)addMembers
{
    VEAddGroupMembersViewController *addMembersVC = [[VEAddGroupMembersViewController alloc] initWithNibName:@"VEAddGroupMembersViewController" bundle:nil];
    addMembersVC.customGroupAgent = self.singleGroupAgent;
    addMembersVC.addGroupMember = ^(Group *customGroupAgent){
        self.singleGroupAgent = customGroupAgent;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:addMembersVC animated:YES];
}

- (void)deleteCustomMemberGroupAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.singleGroupAgent.groupMember.count)
    {
        GroupMember *contactAgent = self.singleGroupAgent.groupMember[index];
        [self startShowPromptViewWithTip:[NSString stringWithFormat:@"正在删除成员:%@", contactAgent.name]];
        
        NSDictionary *dict = @{@"customGroupId":[NSString stringWithFormat:@"%ld",self.singleGroupAgent.groupId],
                               @"contactUid":[NSString stringWithFormat:@"%ld",contactAgent.uid]
                               };
        [GroupTool deleteCustomGroupContactWithParamters:dict resultInfo:^(BOOL success, id JSON) {
            if (success) {
                [self successToDeleteMemberAtIndex:index];
            }
        }];
    }
}

- (void)successToDeleteMemberAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.singleGroupAgent.groupMember.count)
    {
        [self.singleGroupAgent.groupMember removeObjectAtIndex:index];
    }
    
    [self.tableView reloadData];
}

- (void)changeToGroupName:(NSString *)groupName
{
    NSDictionary *dict = @{
                           @"customGroupId":[NSString stringWithFormat:@"%ld",self.singleGroupAgent.groupId],
                           @"customGroupName":groupName
                           };
    
    [self startShowPromptViewWithTip:@"正在修改组名称,请稍等.."];
    __weak typeof(self) weakSelf = self;
    [GroupTool updateCustomGroupNameWithParamters:dict resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf succeeToChangeGroupName:groupName];
        }
        [weakSelf stopShowPromptView];
    }];
}

- (void)succeeToChangeGroupName:(NSString *)groupName
{
    self.singleGroupAgent.groupName = groupName;
    if (self.addGroupList) {
        self.addGroupList(self.singleGroupAgent);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.singleGroupAgent.groupMember.count + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellGroupIdentifier  = @"CellCustomGroup";
    static NSString *cellNormalIdentifier = @"CellCustomGroupNormal";
    
    NSInteger row = indexPath.row;
    if (row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellNormalIdentifier];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellNormalIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
            UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 40)];
            backView.image = [QCZipImageTool imageNamed:kWhiteBK];
            
            [cell.contentView insertSubview:backView atIndex:0];
        }
        
        if (self.textFiledGroupName == nil){
            UITextField *textFiledGroupName = [[UITextField alloc] initWithFrame:CGRectMake(100, 5, Main_Screen_Width - 130, 30)];
            textFiledGroupName.delegate = self;
            textFiledGroupName.font = [UIFont boldSystemFontOfSize:17.0f];
            textFiledGroupName.textColor = readFontColor;
            textFiledGroupName.textAlignment = NSTextAlignmentRight;
            textFiledGroupName.clearButtonMode = UITextFieldViewModeWhileEditing;
            textFiledGroupName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            self.textFiledGroupName = textFiledGroupName;
        }
        
        if ([self.textFiledGroupName superview] != cell.contentView){
            [cell.contentView addSubview:self.textFiledGroupName];
            [cell.contentView sizeToFit];
            [cell sizeToFit];
        }
        
        self.textFiledGroupName.text = self.singleGroupAgent.groupName;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @" 组名称";
         return cell;
    }else{
        VETableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellGroupIdentifier];
        if (cell == nil){
            NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:@"VETableViewCell" owner:self options:nil];
            cell = [cellNib objectAtIndex:VETableViewCellCustomGroupIndex];
        }
        
        UILabel *cellLableTitle  = (UILabel *)[cell viewWithTag:kCellTitleTag];
        cellLableTitle.text = nil;
        UIImageView *sortImgView = (UIImageView *)[cell viewWithTag:kCellImgLogTag];
        sortImgView.hidden  = YES;
        
        if (row == 1){
            cellLableTitle.text = @"添加组成员";
            [cell.deleteBtn setImage:[QCZipImageTool imageNamed:@"icon_group_add.png"] forState:UIControlStateNormal];
        }
        else if (row > 1){
            NSInteger index = (row - 2);
            if (index >= 0 && index < self.singleGroupAgent.groupMember.count){
                [cell.deleteBtn setImage:[QCZipImageTool imageNamed:@"icon_delete.png"] forState:UIControlStateNormal];
                cellLableTitle.text = ((GroupMember *)[self.singleGroupAgent.groupMember objectAtIndex:index]).name;
            }
        }
        cell.deleteGroupItem = ^(){
            [self deleteGroupItem:(indexPath.row - 2)];
        };
        return cell;
    }
}

-(void)deleteGroupItem:(NSInteger)tag{
    [self dismissKeyBorad];
    
    if (tag == -1) {
        [self addMembers];
        return;
    }
    
    NSString *message = nil;
    if (tag >= 0 && tag < self.singleGroupAgent.groupMember.count) {
        message = ((GroupMember *)[self.singleGroupAgent.groupMember objectAtIndex:tag]).name;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"是否删除成员:%@", message] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteCustomMemberGroupAtIndex:tag];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissKeyBorad];
    if (indexPath.row == 1)
    {
        [self addMembers];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyBorad
{
    if ([self.textFiledGroupName isFirstResponder])
    {
        [self.textFiledGroupName resignFirstResponder];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyBorad];
}

@end
