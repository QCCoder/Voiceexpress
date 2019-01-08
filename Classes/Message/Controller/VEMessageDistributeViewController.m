//
//  VEMessageDistributeViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/16.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEMessageDistributeViewController.h"
#import "VENTokenField.h"
#import "PhotoView.h"
#import "MessageTool.h"
#import "QCPhoto.h"
#import "GroupTool.h"
#import "DistributeRequest.h"
#import "VEGroupListViewController.h"
@interface VEMessageDistributeViewController ()<VENTokenFieldDataSource,VENTokenFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *titleLine;
@property (weak, nonatomic) IBOutlet VENTokenField *tokenTextField;
@property (nonatomic,weak)  IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addGroupBtn;
@property (weak, nonatomic) IBOutlet PhotoView *photoView;
@property (weak, nonatomic) IBOutlet UIView *receiverView;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *typeText;
@property (weak, nonatomic) IBOutlet UILabel *levelText;
@property (weak, nonatomic) IBOutlet UIView *sendView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recervierHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reH;

@property (nonatomic, strong ) WarnningTypeAgent         *warnTypeAgent;
@property (nonatomic,strong) NSArray *warnTypeList;
@property (nonatomic,strong) NSMutableArray *selectedContacts;
@property (nonatomic,strong) NSMutableArray *checkedContactsList;

@property (nonatomic,strong) GroupList *groupsList;
@property (nonatomic,strong) NSMutableArray *dataList;
@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,assign) BOOL isSendMsg;


@end

@implementation VEMessageDistributeViewController

#pragma mark 懒加载
-(UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 83, self.view.ve_width, self.view.ve_height)];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

-(NSMutableArray *)dataList
{
    if (!_dataList) {
        NSMutableArray *name = [[NSMutableArray alloc]init];
        self.dataList = name;
    }
    return _dataList;
}

-(NSMutableArray *)selectedContacts
{
    if (!_selectedContacts) {
        _selectedContacts = [NSMutableArray array];
    }
    return _selectedContacts;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    [self setupUI];

    [self setupPhotoView];
    
    [self loadWarnType];
    
    [self loadGroupList];
    
    if (self.agent) {
        [self setContent];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"SendMessage Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"SendMessage Disappear");
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _levelText.ve_width = Main_Screen_Width - 93;
    _typeText.ve_width = Main_Screen_Width - 122;
}

#pragma mark 方法
-(void)setContent{
    self.titleTextField.text = self.agent.title;
    self.contentView.text = self.agent.articleContent;

    _warnTypeAgent = [[WarnningTypeAgent alloc]init];
    _warnTypeAgent.levelName = self.agent.levelName;
    _warnTypeAgent.levelCode = self.agent.levelCode;
    _warnTypeAgent.levelColor = self.agent.levelColor;
    _warnTypeAgent.levelTip = self.agent.levelTip;
    _levelText.text = _warnTypeAgent.levelName;
    
    if (_levelText.text.length == 0) {
        _warnTypeAgent = nil;
        _levelText.text = @"无";
    }
    
    switch (self.columnType) {
        case IntelligenceColumnInstant:
            _typeText.text = self.config[IntelligenceInstant];
            break;
        case IntelligenceColumnDaily:
            _typeText.text = self.config[IntelligenceDaily];
            break;

        case IntelligenceColumnInternational:
            _typeText.text = self.config[IntelligenceInternational];
            break;

        default:
            _typeText.text = self.config[IntelligenceInstant];
            break;
    }
    
    [self.photoView.assets addObjectsFromArray:self.imageUrls];
}

-(void)setup{
    
    _checkedContactsList = [NSMutableArray array];
    _groupsList = [[GroupList alloc]init];
    
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(distributeAlert) image:Config(Tab_Icon_Ok) highImage:nil];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goBack) image:Config(Tab_Icon_Back) highImage:nil];
    
    self.title = self.config[WarnAlert];
    
    
}

-(void)setupUI{
    self.scrollView.alwaysBounceVertical = YES;
    
    [_addGroupBtn setImage:[QCZipImageTool imageNamed:self.config[Icon_Group_Add]] forState:UIControlStateNormal];
    UITapGestureRecognizer *levelGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedLevel:)];
    [_levelText addGestureRecognizer:levelGesture];
    _levelText.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *typeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedType:)];
    [_typeText addGestureRecognizer:typeGesture];
    _typeText.userInteractionEnabled = YES;
    
    self.tokenTextField.toLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.tokenTextField.toLabelTextColor = readFontColor;
    self.tokenTextField.dataSource = self;
    self.tokenTextField.delegate = self;
    self.tokenTextField.toLabelText = self.config[Recriver];
    [self.tokenTextField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.tokenTextField.maxHeight = 5000;
    self.tokenTextField.minInputWidth = 50;
    self.contentView.delegate = self;
}


-(void)setupPhotoView{
    _photoView.addImage = ^(){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addImageFromeCamera];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addImageFromPickVer];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    _photoView.clickImage = ^(id view,NSInteger index){
        [self clickImage:view index:index];
    };
    
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_sendView.frame) + 200);
}

-(void)addContact:(NSArray *)contactList{
    self.tableView.hidden = YES;
    for (GroupMember *member in contactList) {
        BOOL isExit = NO;
        for (GroupMember *groupMember in self.selectedContacts) {
            if (groupMember.uid == member.uid) {
                isExit = YES;
                break;
            }
        }
        if (isExit == NO) {
            [self.selectedContacts addObject:member];
        }
    }
    
    [self.tokenTextField reloadData];
    [self.tokenTextField becomeFirstResponder];
}

-(void)updateDatalist:(NSString *)searchString{
    if (searchString.length > 0) {
        [self.dataList removeAllObjects];
        for (Group *group in self.groupsList.allUsersList) {
            NSMutableArray *searchItemsPredicate = [NSMutableArray array];
            
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
                [self.dataList addObject:aGroup];
            }
        }
    }
    if (self.dataList.count == 0) {
        self.tableView.hidden = YES;
    }
    [self.tableView reloadData];
}

- (void)tokenFieldResignResponser
{
    [self.tokenTextField resignFirstResponder];
    [self.tokenTextField collapse];
    self.tableView.hidden = YES;
    
    self.toTop.constant = 84;
    self.recervierHeight.constant = 40;
    self.reH.constant = 40;

}

/**
 *  加载预警等级
 */
-(void)loadWarnType{
    [MessageTool loadWarnTypeAgent:^(id JSON) {
        _warnTypeList = JSON;
    }];
}

/**
 *  加载联系人
 */
-(void)loadGroupList{
    
//    [MBProgressHUD showMessage:@"" toView:self.view];
    [GroupTool loadGroupListWith:^(BOOL success, id JSON) {
//        [MBProgressHUD hideHUDForView:self.view];
        _groupsList = JSON;
    }];
}


/**
 *  获取收信人列表
 */
- (NSString *)retrieveCheckedContactsList
{
    NSString *allContacts = [NSString string];
    for (GroupMember *checkedAgent in self.selectedContacts)
    {
        allContacts = [allContacts stringByAppendingFormat:@"%ld", (long)checkedAgent.uid];
        if (checkedAgent != [self.selectedContacts lastObject])
        {
            allContacts = [allContacts stringByAppendingString:@"_"];
        }
    }
    return allContacts;
}

#pragma mark 事件监听
- (IBAction)selectedType:(id)sender {
    [self.view endEditing:YES];
    [self tokenFieldResignResponser];

    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [array addObject:[UIAlertAction actionWithTitle:self.config[IntelligenceInstant] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _typeText.text = action.title;
        self.columnType = IntelligenceColumnInstant;
    }]];
    
    [array addObject:[UIAlertAction actionWithTitle:self.config[IntelligenceDaily] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _typeText.text = action.title;
        self.columnType = IntelligenceColumnDaily;
    }]];
    
    [array addObject:[UIAlertAction actionWithTitle:self.config[IntelligenceInternational] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _typeText.text = action.title;
        self.columnType = IntelligenceColumnInternational;
    }]];
    
    [UIAlertController showActionSheetWithtitle:nil message:nil target:self alertActions:array];
}

- (IBAction)selectedLevel:(id)sender {
    [self.view endEditing:YES];
    [self tokenFieldResignResponser];

    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    for (WarnningTypeAgent *warn in self.warnTypeList) {
        [array addObject:[UIAlertAction actionWithTitle:warn.levelName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _warnTypeAgent = warn;
            _levelText.text = warn.levelName;
        }]];
    }
    [UIAlertController showActionSheetWithtitle:nil message:nil target:self alertActions:array];
}

- (IBAction)addGroup:(id)sender {
    [self.view endEditing:YES];
    VEGroupListViewController *contactViewController = [[VEGroupListViewController alloc]init];
    contactViewController.selectedList = self.selectedContacts;
    contactViewController.selectedContacts = ^(NSMutableArray *array){
        self.selectedContacts = [NSMutableArray arrayWithArray:array];
        [self.tokenTextField reloadData];
        [self.tokenTextField becomeFirstResponder];
    };
    [self.navigationController pushViewController:contactViewController animated:YES];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addImageFromPickVer{
    ZLPhotoPickerViewController *pickerVC = [[ZLPhotoPickerViewController alloc] init];
    pickerVC.maxCount = 6 - _photoView.assets.count;
    pickerVC.status = PickerViewShowStatusCameraRoll;
    pickerVC.callBack = ^(NSArray *status){
        [_photoView addImageWithNSArray:status];
    };
    [pickerVC showPickerVc:self];
}

/**
 *  拍照
 */
-(void)addImageFromeCamera{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    cameraVc.maxCount = 1;
    __weak typeof(self) weakSelf = self;
    cameraVc.callback = ^(NSArray *cameras){
        [weakSelf.photoView addImageWithNSArray:cameras];
    };
    [cameraVc showPickerVc:self];
}

/**
 *  查看图片
 */
-(void)clickImage:(id)view index:(NSInteger)index{
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC2 show:self type:PhotoBroswerVCTypeZoom index:index photoModelBlock:^NSArray *{
        NSMutableArray *modelM = [NSMutableArray arrayWithCapacity:weakSelf.photoView.assets.count];
        NSMutableArray *array = weakSelf.photoView.assets;
        for (NSUInteger i = 0; i < array.count; i++) {
            PhotoModel *phModel = [[PhotoModel alloc]init];
            phModel.mid = i+1;
            phModel.image = [array[i] originImage];
            phModel.sourceImageView = view;
            [modelM addObject:phModel];
        }
        return modelM;
    }];
}

-(void)distributeAlert{
    [self.view endEditing:YES];
    if (self.titleTextField.text == 0) {
        [AlertTool showAlertToolWithMessage:@"标题不能为空，请填写标题。"];
        return;
    }
    
    if (self.selectedContacts.count == 0) {
        [AlertTool showAlertToolWithMessage:@"联系人不能为空，请添加联系人。"];
        return;
    }
    
    if (self.contentView.text == 0) {
        [AlertTool showAlertToolWithMessage:@"内容不能为空，请填写内容。"];
        return;
    }
    
    if (self.typeText.text.length == 0) {
        [AlertTool showAlertToolWithMessage:@"类型不能为空，请选择类型。"];
        return;
    }
    
    if (_isSendMsg == YES) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"正在发布，请稍后..." toView:self.view.window];
    DistributeRequest *request = [[DistributeRequest alloc]init];
    request.content = [DES3Util encrypt:self.contentView.text];
    request.title = [DES3Util encrypt:self.titleTextField.text];
    request.proposals = _agent.suggest;
    request.numberTitle = _agent.numberTitle;
    request.level = @"3";
    request.exchangeType = [NSString stringWithFormat:@"%ld",self.columnType];
    request.sendtype = [NSString stringWithFormat:@"%ld",self.sendType];
    if (!self.warnTypeAgent) {
        if (!self.warnTypeList) {
            self.warnTypeAgent = [[WarnningTypeAgent alloc] init];
            self.warnTypeAgent.levelTip = @"";
            self.warnTypeAgent.levelCode = @"";
        }else{
            self.warnTypeAgent = self.warnTypeList[0];
        }
    }
    request.contacts = [self retrieveCheckedContactsList];
    request.levelCode = _warnTypeAgent.levelCode;
    request.levelTip = _warnTypeAgent.levelTip;
    
    
    _isSendMsg = YES;
    [MessageTool distributeAlert:request imageList:self.photoView.assets resultInfo:^(BOOL success, id JSON) {
//        [MBProgressHUD hideHUD];
        _isSendMsg = NO;
        if (success) {
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@"发送成功"];
            if (self.sendSuccess) {
                self.sendSuccess();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@"发送失败，请重新提交"];
        }
    }];
}

#pragma mark - 代理方法
#pragma mark UITableView 数据源&代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Group *group = self.dataList[section];
    return group.groupMember.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.textColor = plainTextColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    Group *group = self.dataList[indexPath.section];
    GroupMember *member = group.groupMember[indexPath.row];
    cell.textLabel.text = member.name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    Group *group = self.dataList[section];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    lable.font = [UIFont boldSystemFontOfSize:14];
    lable.text = [NSString stringWithFormat:@"    %@", group.groupName];
    lable.backgroundColor = selectedBackgroundColor;
    return lable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataList.count ==0) {
        return 0;
    }
    return 25;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Group *group = self.dataList[indexPath.section];
    GroupMember *member = group.groupMember[indexPath.row];
    NSArray *array = @[member];
    [self addContact:array];
    self.tableView.hidden = YES;
    [self.tableView setContentOffsetY:0];
}


#pragma mark 收件人代理
-(void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text{
    [self tokenFieldResignResponser];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    if (index < self.selectedContacts.count)
    {
        [self.selectedContacts removeObjectAtIndex:index];
    }
    [self.tokenTextField reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tokenTextField becomeFirstResponder];
    });
}

- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    if (text.length > 0)
    {
        self.tableView.hidden = NO;
        self.scrollView.contentOffset = CGPointMake(0, self.recervierHeight.constant - 41);
        [self updateDatalist:text];
    }else{
        self.tableView.hidden = YES;
    }
}

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    if (index < self.selectedContacts.count){
        GroupMember *contactAgent = [self.selectedContacts objectAtIndex:index];
        return contactAgent.name;
    }
    return @"";
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return self.selectedContacts.count;
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    NSString *tip = nil;
    if (self.selectedContacts.count > 0)
    {
        GroupMember *contactAgent = [self.selectedContacts objectAtIndex:0];
        tip = contactAgent.name;
        if (self.selectedContacts.count > 1){
            GroupMember *contactAgent2 = [self.selectedContacts objectAtIndex:1];
            tip = [NSString stringWithFormat:@"%@ %@", tip, contactAgent2.name];
        }
        
        if (self.selectedContacts.count > 2)
        {
            tip = [NSString stringWithFormat:@"%@...等%lu人", tip, (unsigned long)self.selectedContacts.count];
        }
    }
    return tip;
}


- (void)tokenField:(VENTokenField *)tokenField didChangeContentHeight:(CGFloat)height{
    self.receiverView.ve_height = height;
    self.toTop.constant = 44 + height;
    self.recervierHeight.constant = height;
    self.reH.constant = height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,self.sendView.frame.size.height + height + 44);
    self.scrollView.contentOffset = CGPointMake(0, height - 41);
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self tokenFieldResignResponser];
    self.scrollView.contentSize = CGSizeMake(0, 650);
    [self.scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self tokenFieldResignResponser];
}


@end
