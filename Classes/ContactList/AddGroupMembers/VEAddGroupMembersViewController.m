//
//  VEAddGroupMembersViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEAddGroupMembersViewController.h"
#import "VETableViewCell.h"
@interface VEAddGroupMembersViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic, strong) NSMutableArray *contactsList;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic,strong) NSMutableArray *dataList;
@property (nonatomic,strong) NSMutableArray *selectedList;

@end

@implementation VEAddGroupMembersViewController


-(NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc]init];
    }
    return _dataList;
}

-(NSMutableArray *)selectedList
{
    if (!_selectedList) {
         _selectedList = [[NSMutableArray alloc]init];
    }
    return _selectedList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.promptView.layer.cornerRadius = 5.0;

    self.searchDisplayController.searchBar.showsCancelButton = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        if (self.searchDisplayController.searchBar.subviews.count)
        {
            [[self.searchDisplayController.searchBar.subviews objectAtIndex:0] removeFromSuperview];
        }
        for (UIView *subView in self.searchDisplayController.searchBar.subviews)
        {
            if ([subView isKindOfClass:[UITextField class]])
            {
                UITextField *searchField = (UITextField *)subView;
                searchField.textColor = [UIColor blackColor];
                [searchField setBackground: [QCZipImageTool imageNamed:@"field_bg"]];
                [searchField setBorderStyle:UITextBorderStyleNone];
            }
        }
    }
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    // 获取候选列表
    [self retrieveContactsList];
    [self setupNav];
};

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"AddGroupMember Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"AddGroupMember Disappear");
}

-(void)setupNav{
    [self setTitle:@"添加分组成员"];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(submit) image:Config(Tab_Icon_Ok) highImage:nil];
}

#pragma mark - IBAction

- (void)submit
{
    if (self.selectedList.count > 0)
    {
        [self submitAction];
    }else{
        ALERT(nil, @"请您勾选联系人");
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

- (void)retrieveContactsList
{
    [self startShowPromptViewWithTip:@"正在加载数据，请稍等..."];
    [GroupTool loadSelectContactsWithGroupId:self.customGroupAgent.groupId resultInfo:^(BOOL success, id JSON) {
        [self stopShowPromptView];
        if (success) {
            self.contactsList = JSON;
            self.dataList = JSON;
            [self.tableView reloadData];
        }
    }];
}

- (void)submitAction
{
    if (self.selectedList.count == 0)
    {
        return;
    }
    
    NSString *uids = @"";
    GroupMember *lastObj = [self.selectedList lastObject];
    for (GroupMember *contactAgent in self.selectedList)
    {
        uids = [uids stringByAppendingFormat:@"%ld", contactAgent.uid];
        if (contactAgent != lastObj)
        {
            uids = [uids stringByAppendingString:@","];
        }
    }
    
    NSDictionary *dict =@{
                          @"customGroupId":[NSString stringWithFormat:@"%ld",self.customGroupAgent.groupId],
                          @"contactUids":uids
                          };
    
    __weak typeof(self) weakSelf = self;
    [GroupTool addCustomGroupContactWithParamters:dict resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf successToAddMemmbers];
        }
    }];
}

- (void)successToAddMemmbers
{
    if (self.customGroupAgent.groupMember.count == 0) {
        self.customGroupAgent.groupMember = [NSMutableArray array];
    }
    [self.customGroupAgent.groupMember addObjectsFromArray:self.selectedList];
    if (self.addGroupMember) {
        self.addGroupMember(self.customGroupAgent);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Group *groupAgent = self.dataList[section];
    NSInteger rows = groupAgent.groupMember.count;
    return (rows > 0 ? (rows + 1) : 0);  // 加一For全选
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = @"CellContact";
    NSInteger index = VETableViewCellContactIndex;
    NSInteger row = indexPath.row;
    
    VETableViewCell *cell = [VETableViewCell cellWithTableView:tableView index:index indentifier:indentifier];
    Group *group = self.dataList[indexPath.section];
    if (row == 0) {
        cell.favoriteBtn.hidden = YES;
        GroupMember *groupMember = [[GroupMember alloc]init];
        groupMember.isSelected = [self checkIsSelectedAll:group.groupMember];
        groupMember.name = @"全选";
        cell.groupMember = groupMember;
        return cell;
    }else{
        cell.favoriteBtn.hidden = YES;
    }
    cell.groupMember = group.groupMember[row - 1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.row - 1;
    
    Group *group = self.dataList[indexPath.section];
    if (group.groupMember.count != 0 && indexPath.row == 0) {//全选
        BOOL isSelectedAll = [self checkIsSelectedAll:group.groupMember];
        NSMutableArray *array = [NSMutableArray array];
        for (GroupMember *member in group.groupMember) {
            member.isSelected = !isSelectedAll;
            [array addObject:member];
        }
        group.groupMember = array;
        [self refreshSelectedList:nil];
    }else if(index>=0 && index < group.groupMember.count){//点击选择一个
        GroupMember *member = group.groupMember[index];
        member.isSelected = !member.isSelected;
        group.groupMember[index]= member;
        self.dataList[indexPath.section]= group;
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:member];
        [self refreshSelectedList:array];
    }
    
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Group *groupAgent = self.dataList[section];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    lable.font = [UIFont boldSystemFontOfSize:14];
    lable.text = [NSString stringWithFormat:@"    %@", groupAgent.groupName];
    lable.backgroundColor = selectedBackgroundColor;
    
    return lable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateDatalist:[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    return YES;
}


#pragma mark - Content Filtering

-(void)updateDatalist:(NSString *)searchString{
    searchString = [searchString lowercaseString];
    if (searchString.length > 0) {
        NSMutableArray *searchList = [NSMutableArray array];
        for (Group *group in self.contactsList) {
            NSMutableArray *searchItemsPredicate = [NSMutableArray array];
            
            NSPredicate *name = [GroupTool predicateWithLeftPath:@"name" rightPath:searchString];
            [searchItemsPredicate addObject:name];
            
            NSPredicate *fullNamePinYin = [GroupTool predicateWithLeftPath:@"fullNamePinYin" rightPath:searchString];
            [searchItemsPredicate addObject:fullNamePinYin];
            
            NSPredicate *predicate1 = [GroupTool predicateWithLeftPath:@"firstLetterPinYin" rightPath:[searchString substringToIndex:1]];
            NSCompoundPredicate *andMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:fullNamePinYin, predicate1, nil]];
            [searchItemsPredicate addObject:andMatchPredicates];
            
            NSPredicate *firstLetterPinYin =  [GroupTool predicateWithLeftPath:@"firstLetterPinYin" rightPath:searchString];
            [searchItemsPredicate addObject:firstLetterPinYin];
            
            NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
            NSMutableArray *groupMembers = [[group.groupMember filteredArrayUsingPredicate:orMatchPredicates] mutableCopy];
            if (groupMembers.count > 0) {
                Group *aGroup = [[Group alloc]init];
                aGroup.groupMember = groupMembers;
                aGroup.groupId = group.groupId;
                aGroup.groupName = group.groupName;
                [searchList addObject:aGroup];
            }
        }
        self.dataList = searchList;
    }
    [self.tableView reloadData];
}

-(BOOL)checkIsSelectedAll:(NSArray *)array{
    NSInteger index=0;
    for (GroupMember *groupMember in array) {
        if (groupMember.isSelected) {
            index++;
        }
    }
    if (index == array.count) {
        return YES;
    }
    return NO;
}

-(void)refreshSelectedList:(NSArray *)data{
    
    [self.selectedList removeAllObjects];
    for (Group *group in self.dataList) {
        for (GroupMember *member in group.groupMember) {
            if (member.isSelected) {
                [self.selectedList addObject:member];
            }
        }
    }

}



@end
