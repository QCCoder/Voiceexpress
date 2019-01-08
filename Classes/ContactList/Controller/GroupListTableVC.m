//
//  GroupListTableVC.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "GroupListTableVC.h"
#import "GroupTool.h"
#import "VETableViewCell.h"
@interface GroupListTableVC ()<UISearchBarDelegate>

@property (nonatomic,weak) UISearchBar *searchBar;

@property (nonatomic,weak) UIButton *btnAccessoryView;

@property (nonatomic, strong) NSMutableDictionary   *foldGroupResults;

@property (nonatomic,strong) NSMutableArray *backupList;
@end

@implementation GroupListTableVC

-(NSMutableArray *)selectedList
{
    if (!_selectedList) {
        _selectedList = [[NSMutableArray alloc]init];
    }
    return _selectedList;
}

-(NSMutableArray *)backupList
{
    if (!_backupList) {
        _backupList = [[NSMutableArray alloc]init];
    }
    return _backupList;
}

-(UISearchBar *)searchBar
{
    if (!_searchBar){
        UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 44)];
        [self.view addSubview:searchBar];
        [searchBar setPlaceholder:@"搜索"];
        searchBar.delegate = self;
        searchBar.hidden = YES;
        [searchBar setShowsCancelButton:NO animated:NO];
        self.searchBar = searchBar;
    }
    return _searchBar;
}

-(UIButton *)btnAccessoryView{
    if (!_btnAccessoryView) {
        UIButton *btnAccessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAccessoryView setFrame:CGRectMake(0, 44, Main_Screen_Width, self.view.frame.size.height - 44)];
        [btnAccessoryView setBackgroundColor:[UIColor blackColor]];
        [btnAccessoryView setAlpha:0.0f];
        [btnAccessoryView addTarget:self action:@selector(ClickControlAction:)forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnAccessoryView];
        self.btnAccessoryView = btnAccessoryView;
    }
    return _btnAccessoryView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.header = nil;
    self.cellHeight = 50;
    if (self.groupType == GroupTypeAll) {
        self.searchBar.hidden = NO;
        self.tableView.ve_y = 44;
    }
}

-(void)loadNewMsg{
    
}


-(void)setDatalist:(NSMutableArray *)datalist{
    [super setDatalist:datalist];
    
    if (self.groupType == GroupTypeCustom) {
        [self initFoldGroupResults];
    }
    
    if (datalist.count > 0) {
        [self.tableView reloadData];
    }
    
}

-(BOOL)checkIsSelectedAll:(NSArray *)array{
    if (array.count == 0) {
        return NO;
    }
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


-(void)updateFavorite:(GroupMember *)groupMember indexPath:(NSIndexPath *)indexPath indicator:(UIActivityIndicatorView *)indicator{
    // 0: 添加常用联系人
    // 1: 删除常用联系人
    NSString *type = @"0";
    if (groupMember.isContact) {
        type = @"1";
    }
    NSDictionary *dict = @{
                           @"fuid":[NSString stringWithFormat:@"%ld",groupMember.uid],
                           @"type":type
                           };
    groupMember.isContact = !groupMember.isContact;
    [indicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [GroupTool updateFavoriteContactWith:dict resultInfo:^(BOOL success, id JSON) {
        [indicator stopAnimating];
        if (success) {
            Group *group = weakSelf.datalist[indexPath.section];
            if (weakSelf.groupType == GroupTypeContacts) {
                [group.groupMember removeObjectAtIndex:(indexPath.row - 1)];
            }else{
                group.groupMember[indexPath.row - 1] = groupMember;
            }
            weakSelf.datalist[indexPath.section] = group;
            [weakSelf.tableView reloadData];
            
            if (weakSelf.favorite) {
                weakSelf.favorite(weakSelf.groupType,groupMember);
            }
        }
    }];
}

-(void)refreshSelectedList:(NSArray *)data{
    
    if (self.groupType != GroupTypeContacts) {
        [self.selectedList removeAllObjects];
        for (Group *group in self.datalist) {
            for (GroupMember *member in group.groupMember) {
                if (member.isSelected) {
                    [self.selectedList addObject:member];
                }
            }
        }
    }else if (self.groupType == GroupTypeContacts){
        for (GroupMember *selectedMember in data) {
            BOOL selected = NO;
            NSInteger index = 0;
            for (GroupMember *member in self.selectedList) {
                if (member.uid == selectedMember.uid) {
                    if (member.isSelected) {
                        [self.selectedList removeObjectAtIndex:index];
                    }
                    selected = YES;
                    break;
                }
                index++;
            }
            if (!selected) {
                selectedMember.isSelected = YES;
                [self.selectedList addObject:selectedMember];
            }
        }
    }
    
    if (self.getSelectedList) {
        self.getSelectedList(self.groupType,self.selectedList);
    }
}


-(void)setContactMember:(GroupMember *)groupMember{
    if (self.groupType == GroupTypeAll) {
        
        NSInteger i = 0;
        NSInteger j = 0;
        BOOL isRemove = NO;
        for (Group *group in self.datalist) {
            for (GroupMember *member in group.groupMember) {
                if (member.uid == groupMember.uid) {
                    member.isContact = groupMember.isContact;
                    group.groupMember[j] = member;
                    isRemove = YES;
                    break;
                }
                j++;
            }
            if (isRemove) {
                self.datalist[i] = group;
                break;
            }
            i++;
        }
        
    }else if(self.groupType == GroupTypeContacts){
        NSInteger isExit = NO;
        for (Group *group in self.datalist) {
            for (GroupMember *member in group.groupMember) {
                if (member.uid == groupMember.uid) {
                    [group.groupMember removeObject:member];
                    self.datalist[0] = group;
                    isExit = YES;
                    break;
                }
            }
        }
        if (isExit==NO) {
            
            Group *group = self.datalist[0];
            [group.groupMember addObject:groupMember];
            self.datalist[0] = group;
        }
    }
    [self.tableView reloadData];
}

-(void)setSelectedData:(NSMutableArray *)array{
    self.selectedList = array;
    
    for (int i = 0; i < self.datalist.count ; i++) {
        Group *group = self.datalist[i];
        for (int j = 0; j < group.groupMember.count ; j++) {
            GroupMember *member = group.groupMember[j];
            member.isSelected = NO;
            for (GroupMember *selectMember in array) {
                if (selectMember.uid == member.uid) {
                    member.isSelected = YES;
                    break;
                }
            }
            group.groupMember[j] = member;
        }
        self.datalist[i]= group;
    }
    [self.tableView reloadData];
}

- (void)initFoldGroupResults
{
    self.foldGroupResults = [NSMutableDictionary dictionary];
    [self.foldGroupResults removeAllObjects];
    
    for (Group *groupAgent in self.datalist)
    {
        [self.foldGroupResults setValue:@"1"  // 折叠
                                 forKey:[[NSNumber numberWithInteger:groupAgent.groupId] stringValue]];
    }
}

- (BOOL)isGroupIdFolded:(NSInteger)groupId
{
    return [[self.foldGroupResults valueForKey:[[NSNumber numberWithInteger:groupId] stringValue]] boolValue];
}

- (void)setGroupId:(NSInteger)groupId OnFold:(BOOL)bFolded
{
    NSString *fold = (bFolded ? @"1" : @"0");
    [self.foldGroupResults setValue:fold
                             forKey:[[NSNumber numberWithInteger:groupId] stringValue]];
}


-(void)selectItem:(UITapGestureRecognizer *)gestrue{
    NSInteger tag = gestrue.view.tag;
    Group *group = self.datalist[tag];
    BOOL isSelectedAll = [self checkIsSelectedAll:group.groupMember];
    NSMutableArray *array = [NSMutableArray array];
    for (GroupMember *member in group.groupMember) {
        member.isSelected = !isSelectedAll;
        [array addObject:member];
    }
    group.groupMember = array;
    [self refreshSelectedList:nil];
    [self.tableView reloadData];
}


#pragma mark 事件监听
- (void) ClickControlAction:(id)sender{
    [self controlAccessoryView:0 IsEditing:NO];
}
// 控制遮罩层的透明度
- (void)controlAccessoryView:(float)alphaValue IsEditing:(BOOL)editing{
    
    [UIView animateWithDuration:0.2 animations:^{
        //动画代码
        [self.btnAccessoryView setAlpha:alphaValue];
        
    }completion:^(BOOL finished){
        if (alphaValue<=0) {
            if (editing) {
                
            }else{
                [_searchBar resignFirstResponder];
                [_searchBar setShowsCancelButton:NO animated:YES];
            }
        }
    }];
}

#pragma mark - TableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datalist.count ==0) {
        return 0;
    }
    Group *group = self.datalist[section];
    if (group.groupMember.count == 0) {
        return 0;
    }
    
    if (self.groupType != GroupTypeCustom) {
        return group.groupMember.count + 1;
    }else{
        if ([self isGroupIdFolded:group.groupId]) {
            return 0;
        }
        return group.groupMember.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView hasResultCellRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *indentifier = @"CellContact";
    NSInteger index = VETableViewCellContactIndex;
    NSInteger row = indexPath.row;
    if (self.groupType == GroupTypeCustom)
    {
        indentifier = @"CellThirdContact";
        index = VETableViewCellThirdContactIndex;
    }else{
        row = indexPath.row - 1;
    }
    
    VETableViewCell *cell = [VETableViewCell cellWithTableView:tableView index:index indentifier:indentifier];
    Group *group = self.datalist[indexPath.section];
    
    if (self.groupType == GroupTypeCustom) {
        GroupMember *member = group.groupMember[indexPath.row];
        cell.thirdTitleLabel.text = member.name;
        NSString *imageName = (member.isSelected ? @"icon_check_selected.png" : @"icon_check_normal.png");
        [cell.thirdBtn setImage:[UIImage imageNamed:imageName]];
        return cell;
    }
    
    
    if (row == -1 && self.groupType != GroupTypeCustom) {
        cell.favoriteBtn.hidden = YES;
        GroupMember *groupMember = [[GroupMember alloc]init];
        groupMember.isSelected = [self checkIsSelectedAll:group.groupMember];
        groupMember.name = @"全选";
        cell.groupMember = groupMember;
        return cell;
    }else{
        cell.favoriteBtn.hidden = NO;
    }
    cell.groupMember = group.groupMember[row];
    cell.indexPath = indexPath;
    cell.doFavorite = ^(GroupMember *groupMember,NSIndexPath *indexPath,UIActivityIndicatorView *indicator){
        [self updateFavorite:groupMember indexPath:indexPath indicator:indicator];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.datalist.count==0) {
        return nil;
    }
    Group *group = self.datalist[section];
    if (self.groupType != GroupTypeCustom) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
        lable.font = [UIFont boldSystemFontOfSize:14];
        lable.text = [NSString stringWithFormat:@"    %@", group.groupName];
        lable.backgroundColor = selectedBackgroundColor;
        return lable;
    }else{
        VETableViewCell *headerView = [VETableViewCell cellWithTableView:tableView index:VETableViewCellCellSecondContactIndex indentifier:@"CellSecondContact"];
        BOOL isChecked = [self checkIsSelectedAll:group.groupMember];
        NSString *imageName = (isChecked ? @"icon_check_selected.png" : @"icon_check_normal.png");
        headerView.selectBtn.image = [QCZipImageTool imageNamed:imageName];
        headerView.secondTitleLabel.text = group.groupName;
        BOOL isFold = [self isGroupIdFolded:group.groupId];
        headerView.secondBtn.selected = isFold;
        [headerView.secondBtn setImage:[QCZipImageTool imageNamed:@"icon_group_up.png"] forState:UIControlStateNormal];
        [headerView.secondBtn setImage:[QCZipImageTool imageNamed:@"icon_group_down.png"] forState:UIControlStateSelected];
        headerView.tag = section;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectItem:)];
        [headerView addGestureRecognizer:gesture];
        headerView.showAll = ^(UIButton *btn){
            [self setGroupId:group.groupId OnFold:!isFold];
            [self.tableView reloadData];
        };
        return headerView;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.datalist.count ==0) {
        return 0;
    }
    
    if (self.groupType == GroupTypeCustom) {
        return 50;
    }
    
    return 25;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.row;
    if (self.groupType != GroupTypeCustom) {
        index = indexPath.row - 1;
    }
    
    Group *group = self.datalist[indexPath.section];
    if (group.groupMember.count != 0 && indexPath.row == 0 && self.groupType == GroupTypeAll) {//全选
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
        self.datalist[indexPath.section]= group;
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:member];
        [self refreshSelectedList:array];
    }
    
    [self.tableView reloadData];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.backupList = self.datalist;
    [self controlAccessoryView:0.2 IsEditing:NO];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.backupList = self.datalist;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        [self controlAccessoryView:0.2 IsEditing:NO];
        self.datalist = self.backupList;
    }else{
        [self controlAccessoryView:0 IsEditing:YES];
        [self updateDatalist:searchText];
    }
}

-(void)updateDatalist:(NSString *)searchString{
    if (searchString.length > 0) {
        NSMutableArray *searchList = [NSMutableArray array];
        for (Group *group in self.datalist) {
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
        self.datalist = searchList;
    }
    [self.tableView reloadData];
}



@end
