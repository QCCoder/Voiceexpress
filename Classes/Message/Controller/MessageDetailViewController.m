//
//  MessageDetailViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "MessageDetailResponse.h"
#import "DetailHeadView.h"
#import "InstantContentView.h"
#import "VEReceiversTableViewCell.h"
#import "VEReplyTableViewCell.h"
#import "UrlModel.h"
#import "NormalHead.h"
#import "PhotoBroswerVC2.h"
#import "VECommentViewController.h"
#import "ArticledetailTool.h"
#import "VEMessageDistributeViewController.h"

static const NSInteger kTableCellReceiverHeight       = 30;

@interface MessageDetailViewController ()<UITableViewDataSource,UITableViewDelegate,SNScrollViewDelegate,ArticleDelegate>

@property (nonatomic,weak  ) UIScrollView       *scrollView;

//收件人，发件人View
@property (nonatomic,weak  ) DetailHeadView     *headView;

//网安快报标题等View
@property (nonatomic,weak  ) InstantContentView *instantContentView;

//网安每日舆情，外宣每日舆情，情报交互信息
@property (nonatomic,weak  ) NormalHead         *normalHead;

//缩略图信息图片
@property (nonatomic,strong) NSArray            *imageUrls;
@property (weak, nonatomic ) UIImageView        *imageView;
@property (weak, nonatomic ) UIView             *imageContentView;
@property (weak, nonatomic ) UILabel            *countLabel;

@property (nonatomic,weak  ) UIView             *contentHeadView;

//WebView显示内容
@property (nonatomic,weak  ) SNScrollView       *snView;

//回复
@property (nonatomic,weak  ) UITableView        *replyTableView;//回复Table
@property (nonatomic,weak  ) UIImageView        *replyBKImageView;//回复选中的背景
@property (nonatomic,weak  ) UIView             *line;
@property (nonatomic,weak  ) UIButton           *btnReplyRelative;
@property (nonatomic,weak  ) UIButton           *btnReplyToMe;
@property (nonatomic,strong) NSArray            *replyList;//当前选中项，回复或相关
@property (nonatomic,strong) ReplyGroup         *replyGroup;//数据源，其中包含回复和相关

@property (weak, nonatomic ) UIButton           *toReplyBtn;
@property (weak, nonatomic ) UIButton           *toTopBtn;

@property (nonatomic,weak  ) UIView             *footView;

@end

@implementation MessageDetailViewController
#pragma mark - 懒加载
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *name = [[UIScrollView alloc] init];
        name.frame = self.view.bounds;
        name.ve_width = Main_Screen_Width;
        name.ve_height = Main_Screen_Height - 108;
        name.delegate = self;
        [self.view addSubview:name];
        self.scrollView = name;
    }
    return _scrollView;
}

-(UIView *)normalHead
{
    if (!_normalHead) {
        NormalHead *name = [[NormalHead alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), Main_Screen_Width, 90)];
        [self.scrollView addSubview:name];
        self.normalHead = name;
    }
    return _normalHead;
}

-(SNScrollView *)snView
{
    if (!_snView) {
        SNScrollView *sv = [[SNScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentHeadView.frame), Main_Screen_Width, 50)];
        [sv setColorScroller:[UIColor blackColor] withAlpha:.2f];
        [sv setColorSectionDot:[UIColor blackColor] withAlpha:1.0f];
        [sv setColorAccessoryView:[UIColor darkGrayColor] withAlpha:1.0f];
        sv.delegate = self;
        sv.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:sv];
        self.snView = sv;
    }
    return _snView;
}

-(NSArray *)imageUrls
{
    if (!_imageUrls) {
        NSArray *name = [[NSArray alloc]init];
        self.imageUrls = name;
    }
    return _imageUrls;
}

-(InstantContentView *)instantContentView
{
    if (!_instantContentView) {
        InstantContentView *contentView = [[InstantContentView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_headView.frame), Main_Screen_Width, 0)];
        [self.scrollView addSubview:contentView];
        _instantContentView = contentView;
    }
    return _instantContentView;
}

-(UIView *)footView
{
    if (!_footView) {
        UIView *name = [[UIView alloc]initWithFrame:CGRectMake(0, Main_Screen_Height - 108, Main_Screen_Width, 44)];
        DLog(@"%@",self.config[MainColor]);
        [name setBackgroundColor:[UIColor colorWithHexString:self.config[MainColor]]];
        [self.view addSubview:name];
        self.footView = name;
        
        UIButton *forwardBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [forwardBtn addTarget:self action:@selector(doForward) forControlEvents:UIControlEventTouchUpInside];
        [forwardBtn setImage:Image(Icon_Share) forState:UIControlStateNormal];
        [name addSubview:forwardBtn];
        
        UIButton *showList = [[UIButton alloc]initWithFrame:CGRectMake(Main_Screen_Width - 44, 0, 44, 44)];
        [showList setImage:Image(Tab_Icon_More) forState:UIControlStateNormal];
        [showList addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
        [name addSubview:showList];
    }
    return _footView;
}

#pragma mark - 系统方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"正文";
    
//    self.intelligAgent.articleContent = self.config[Loading];
    self.view.backgroundColor = RGBCOLOR(246, 246, 246);
    
    [self loadContent];
    
    //收件人，发件人
    [self setupHeadView];
    
    [self setupContentHead];
    
    [self setupReplyView];
    
    [self loadReply];
    
    [self loadWebView];
    
    [self setupBtn];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"MessageDetail Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"MessageDetail Disappear");
}

-(void)setupBtn{
    
    UIButton *toTopBtn = [[UIButton alloc]initWithFrame:CGRectMake(Main_Screen_Width - 13 - 32, self.view.ve_height - 67 - 88, 32, 32)];
    toTopBtn.hidden = YES;
    [toTopBtn setImage:[QCZipImageTool imageNamed:@"btn_top_normal.png"] forState:UIControlStateNormal];
    [toTopBtn setImage:[QCZipImageTool imageNamed:@"btn_top_pressed.png"] forState:UIControlStateHighlighted];
    [toTopBtn addTarget:self action:@selector(toTop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toTopBtn];
    _toTopBtn = toTopBtn;
    
    UIButton *toReplyBtn = [[UIButton alloc]initWithFrame:CGRectMake(Main_Screen_Width - 13 - 32, CGRectGetMinY(toTopBtn.frame) - 10 - 32, 32, 32)];
    [toReplyBtn setImage:[QCZipImageTool imageNamed:@"btn_replay_normal.png"] forState:UIControlStateNormal];
    [toReplyBtn setImage:[QCZipImageTool imageNamed:@"btn_replay_pressed.png"] forState:UIControlStateHighlighted];
    [toReplyBtn addTarget:self action:@selector(toReply) forControlEvents:UIControlEventTouchUpInside];
    toReplyBtn.hidden = YES;
    [self.view addSubview:toReplyBtn];
    _toReplyBtn = toReplyBtn;
  
}

#pragma mark 我的方法
-(void)setupHeadView{
    DetailHeadView *headView = [[DetailHeadView alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 62)];
    DetilHead *data = [[DetilHead alloc]init];
    data.revicers = self.intelligAgent.receiverNames.count;
    data.sender = self.intelligAgent.author;
    headView.data = data;
    [self.scrollView addSubview:headView];
    _headView = headView;
    _headView.showList= ^(CGFloat heigth){
        _headView.ve_height = heigth;
        [self refreshContent];
    };
    headView.tableView.delegate = self;
    headView.tableView.dataSource = self;
    //加载已读未读信息
    
    
    self.footView.ve_height = 44 ;
}

-(void)setupContentHead{
    if (self.columnType == IntelligenceColumnInstant) {
        self.instantContentView.agent = self.intelligAgent;
        self.contentHeadView = self.instantContentView;
    }else{
        NSString *str = @"";
        if (self.columnType == IntelligenceColumnDaily) {
            str = self.config[IntelligenceDaily];
        }else if(self.columnType == IntelligenceColumnInternational){
            str = self.config[IntelligenceInternational];
        }else{
            str = self.config[IntelligenceAllIntelligence];
        }
        self.normalHead.columnName = str;
        self.normalHead.agent = self.intelligAgent;
        self.contentHeadView = self.normalHead;
    }
}

-(void)setupImageView
{
    if (_imageContentView) {
        return;
    }
    UIView *imageContentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentHeadView.frame), Main_Screen_Width, 255)];
    imageContentView.userInteractionEnabled = YES;
    imageContentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:imageContentView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, Main_Screen_Width - 40, 210)];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageContentView addSubview:imageView];
    _imageView = imageView;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 231, Main_Screen_Width - 40, 21)];
    label.font = [UIFont boldSystemFontOfSize:15.0];
    label.textColor =RGBCOLOR(178, 178, 178);
    [label setTextAlignment:NSTextAlignmentCenter];
    [imageContentView addSubview:label];
    _countLabel = label;
    
    _imageContentView = imageContentView;
}

-(void)setupReplyView{
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.snView.frame), Main_Screen_Width, 28)];
    imageView.image = [QCZipImageTool imageNamed:@"title_reply"];
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    _replyBKImageView = imageView;
    
    UIButton *btnReplyToMe =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 61, 28)];
    btnReplyToMe.selected = YES;
    [btnReplyToMe addTarget:self action:@selector(replyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [btnReplyToMe setTitle:[NSString stringWithFormat:@"%@ 0",self.config[Reply]] forState:UIControlStateNormal];
    [btnReplyToMe setTitleColor:replyCategoryColor forState:UIControlStateNormal];
    [btnReplyToMe setTitleColor:unreadFontColor forState:UIControlStateSelected];
    btnReplyToMe.tag = 0;
    btnReplyToMe.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [imageView addSubview:btnReplyToMe];
    _btnReplyToMe = btnReplyToMe;
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(61, 6, 2, 15)];
    [line setBackgroundColor:RGBCOLOR(228, 228, 228)];
    [imageView addSubview:line];
    _line = line;
    
    UIButton *btnReplyRelative =[[UIButton alloc]initWithFrame:CGRectMake(64, 0, 61, 28)];
    [btnReplyRelative addTarget:self action:@selector(relativeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [btnReplyRelative setTitle:[NSString stringWithFormat:@"%@ 0",self.config[Relative]] forState:UIControlStateNormal];
    [btnReplyRelative setTitleColor:replyCategoryColor forState:UIControlStateNormal];
    [btnReplyRelative setTitleColor:unreadFontColor forState:UIControlStateSelected];
    btnReplyRelative.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    btnReplyRelative.selected = NO;
    btnReplyRelative.tag = 1;
    [imageView addSubview:btnReplyRelative];
    _btnReplyRelative = btnReplyRelative;
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), Main_Screen_Width, 300)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = RGBCOLOR(246, 246, 246);
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollView addSubview:tableView];
    _replyTableView = tableView;
}

-(void)setupReplyList{
    self.replyList = [NSArray array];
    if (self.boxType == BoxTypeRelativeMe || self.columnType == IntelligenceColumnAllIntelligence) {
        self.replyList = self.replyGroup.aboutMe;
        self.line.hidden = YES;
        self.btnReplyRelative.frame = self.btnReplyToMe.frame;
        self.btnReplyRelative.selected = YES;
        self.btnReplyToMe.selected = NO;
        self.btnReplyToMe.hidden = YES;
    }else if(self.boxType == BoxTypeOutput){
        self.replyList = self.replyGroup.toMe;
        self.line.hidden = YES;
        self.btnReplyRelative.hidden = YES;
        self.btnReplyRelative.selected = NO;
        self.btnReplyToMe.hidden = NO;
        self.btnReplyToMe.selected = YES;
    }else{
        if (self.btnReplyRelative.selected) {
            self.replyList = self.replyGroup.aboutMe;
            self.replyBKImageView.image = [QCZipImageTool imageNamed:@"title_related"];
        }else{
            self.replyList = self.replyGroup.toMe;
            self.replyBKImageView.image = [QCZipImageTool imageNamed:@"title_reply"];
        }
        
        self.line.hidden = NO;
        self.btnReplyToMe.hidden = NO;
        self.btnReplyRelative.hidden = NO;
        self.line.hidden = NO;
    }
    
}

-(void)setupNumberOfReply{
    
    NSInteger toMeCount = 0;
    NSInteger relativeCount = 0;
    for (ReplyGroupAgent *groupAgent in self.replyGroup.toMe) {
        toMeCount += groupAgent.replygroup.count;
    }
    
    for (ReplyGroupAgent *groupAgent in self.replyGroup.aboutMe) {
        relativeCount += groupAgent.replygroup.count;
    }
    
    [self.btnReplyToMe setTitle:[NSString stringWithFormat:@"%@ %ld",self.config[Reply],toMeCount] forState:UIControlStateNormal];
    [self.btnReplyRelative setTitle:[NSString stringWithFormat:@"%@ %ld",self.config[Relative],relativeCount] forState:UIControlStateNormal];
}

- (void)commentItemToReceiverID:(NSString *)receiverID andReciverName:(NSString *)receiverName
{
    VECommentViewController *commentViewController = [[VECommentViewController alloc] initWithNibName:@"VECommentViewController" bundle:nil];
    commentViewController.articleID = self.intelligAgent.articleId;
    commentViewController.receiverID = receiverID;
    commentViewController.receiverName = receiverName;
    commentViewController.replySuccess = ^(){
        [self loadReply];
    };
    
    
    [self.navigationController pushViewController:commentViewController animated:YES];
}

-(void)refreshContent{
    self.contentHeadView.ve_y = CGRectGetMaxY(_headView.frame);
    
    if (self.imageUrls.count > 0) {
        [self setupImageView];
        self.imageContentView.hidden = NO;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self action:@selector(imageViewTapped:)];
        [self.imageContentView addGestureRecognizer:tapGestureRecognizer];
        self.imageContentView.ve_y = CGRectGetMaxY(self.contentHeadView.frame);
        [_imageView imageWithUrlStr:[self.imageUrls firstObject] phImage:Image(Icon_Picture_Min)];
        _countLabel.text = [NSString stringWithFormat:@"%@%ld%@", self.config[ImageTip_Left],(unsigned long)self.imageUrls.count,self.config[ImageTip_Right]];
    }else{
        self.imageContentView.hidden = YES;
    }
    
    if (self.intelligAgent.articleContent.length > 0) {
        if (self.imageUrls.count > 0) {
            self.snView.ve_y = CGRectGetMaxY(self.imageContentView.frame);
        }else{
            self.snView.ve_y = CGRectGetMaxY(self.contentHeadView.frame);
        }
        
    }
    
    self.replyBKImageView.ve_y = CGRectGetMaxY(self.snView.frame);
    self.replyTableView.ve_y = CGRectGetMaxY(self.replyBKImageView.frame);
    [self reCalculateReplyTableSize];
    [self cateBtnHidden];
}

#pragma mark - Http请求加载数据
-(void)refreshReceivers{
    DetilHead *data = [[DetilHead alloc]init];
    data.revicers = self.intelligAgent.receivers.count;
    data.sender = self.intelligAgent.author;
    _headView.data =data;
    [_headView.tableView reloadData];
}

-(void)loadContent{
    NSDictionary *dict = @{
                           @"aid":self.intelligAgent.articleId,
                           @"warnType":[NSString stringWithFormat:@"%ld",self.intelligAgent.warnType],
                           @"io":[NSString stringWithFormat:@"%ld", self.boxType - 1]};
    MBProgressHUD *hud = [MBProgressHUD showMessage:@""];
    [MessageTool loadAriticleWithParamters:dict resultInfo:^(BOOL success, id JSON) {
        [hud hide:YES];
        if (success) {
            MessageDetailResponse *response = JSON;
            
            NSString *suggest = [DES3Util decrypt:response.proposals];
            NSString *content = [DES3Util decrypt:response.content];
            NSString *suggestId = response.suggestId;
            NSArray *imageUrls = response.imageUrls;
            
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dict in imageUrls) {
                [array addObject:dict[@"imageUrl"]];
            }
            self.intelligAgent.articleContent = content;
            self.intelligAgent.suggest = suggest;
            self.intelligAgent.suggestId = [suggestId integerValue];
            self.intelligAgent.receivers = [NSMutableArray arrayWithArray:response.receivers];
            self.imageUrls = array;
            
            
            [self refreshReceivers];
            [self loadWebView];
        }else{
            self.intelligAgent.articleContent = @"内容加载失败，请重新加载...";
            [self loadWebView];
        }
    }];
}

-(void)loadWebView{
    if (self.intelligAgent.articleContent.length == 0) {
        return;
    }
    NSString *showContent = [self.intelligAgent.articleContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    showContent = [showContent stringByReplacingOccurrencesOfString:@"　" withString:@""];
    showContent = [showContent stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
    
    showContent = [showContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
    if (self.intelligAgent.suggest.length > 0) {
        showContent = [NSString stringWithFormat:@"%@<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%@",showContent,self.intelligAgent.suggest];
    }
    
    showContent = [UrlModel urlContent:[showContent lowercaseString]];
    [self.snView showcontentWithModelString:showContent];
}

-(void)loadReply{
    [MessageTool loadReplyWithAid:self.intelligAgent.articleId boxType:self.boxType resultInfo:^(BOOL success, id JSON) {
        if (success) {
            self.replyGroup = JSON;
            [self setupNumberOfReply];
            [self setupReplyList];
        }
        [self reCalculateReplyTableSize];
        [_replyTableView reloadData];
    }];
}

#pragma mark - 点击事件

-(void)selectedBtn:(UIButton *)btn{
    if (btn.selected) {
        return;
    }
    if (btn.tag == 0) {//回复
        self.replyList = self.replyGroup.toMe;
        self.line.hidden = YES;
        self.btnReplyRelative.hidden = YES;
        self.btnReplyRelative.selected = NO;
        self.btnReplyToMe.hidden = NO;
        self.btnReplyToMe.selected = YES;
    }else{//相关
        self.replyList = self.replyGroup.aboutMe;
        self.line.hidden = YES;
        self.btnReplyRelative.frame = self.btnReplyToMe.frame;
        self.btnReplyRelative.selected = YES;
        self.btnReplyToMe.selected = NO;
        self.btnReplyToMe.hidden = YES;
    }
}

- (void)imageViewTapped:(UITapGestureRecognizer *)sender
{
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC2 show:self type:PhotoBroswerVCTypeZoom index:0 photoModelBlock:^NSArray *{
        NSMutableArray *modelM = [NSMutableArray arrayWithCapacity:self.imageUrls.count];
        for (NSUInteger i = 0; i < self.imageUrls.count; i++) {
            PhotoModel *phModel = [[PhotoModel alloc]init];
            phModel.mid = i+1;
            phModel.image_HD_U = self.imageUrls[i];
            phModel.sourceImageView = weakSelf.imageView;
            [modelM addObject:phModel];
        }
        return modelM;
    }];
}

-(void)replyBtnClick{
    _btnReplyToMe.selected = YES;
    _btnReplyRelative.selected = NO;
    [self setupReplyList];
    [self.replyTableView reloadData];
}

-(void)relativeBtnClick{
    _btnReplyToMe.selected = NO;
    _btnReplyRelative.selected = YES;
    [self setupReplyList];
    [self.replyTableView reloadData];
}



-(void)showMore{
    ArticledetailTool *detailTool = [[ArticledetailTool alloc]init];
    detailTool.delegate = self;
    [detailTool showWithDeleteList:self agent:self.intelligAgent];
}

-(void)doForward{
    WarnningTypeAgent *agent = [[WarnningTypeAgent alloc]init];
    agent.levelName = self.intelligAgent.levelName;
    agent.levelTip = self.intelligAgent.levelTip;
    agent.levelColor = self.intelligAgent.levelColor;
    agent.levelCode = self.intelligAgent.levelCode;
    
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc]init];
    distributeViewController.columnType             = self.columnType;
    distributeViewController.sendType               = SendTypeForwardFromIntelligence;
    distributeViewController.agent = self.intelligAgent;
    distributeViewController.imageUrls = self.imageUrls;
//    distributeViewController.forwardImageUrls       = self.imageUrls;
//    distributeViewController.forwardArticleContent = [NSString stringWithFormat:@"\n %@",self.intelligAgent.articleContent];
//    distributeViewController.forwardAgent           = self.intelligAgent;
//    distributeViewController.suggest = self.intelligAgent.suggest;
//    distributeViewController.suggestId = self.intelligAgent.suggestId;
//    distributeViewController.forwardFromType        = ForwardFromIntelligenceAlert;
//    distributeViewController.showTitle = self.intelligAgent.numberTitle;
    
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

// 快速到首页

- (void)toTop
{
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.toTopBtn.hidden = YES;
    }completion:^(BOOL finished) {
        [self cateBtnHidden];
    }];
}

// 快速到回复

- (void)toReply
{
    float temp = (self.scrollView.contentSize.height - self.scrollView.frame.size.height);
    float offset = MIN(self.replyTableView.frame.origin.y, temp);
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, offset)];
        [self.replyTableView reloadData];
        
    } completion:^(BOOL finished) {
        [self cateBtnHidden];
    }];
}

// 直接回复主题
- (void)commentItemTapped:(UIButton *)sender
{
    if (sender.tag == kMeReplyBtnTag)
    {
        [self commentItemToReceiverID:@"0" andReciverName:(self.intelligAgent.author ? self.intelligAgent.author : @"")];
    }
}

#pragma mark - UITableView 数据源&代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _headView.tableView) {
        return (self.intelligAgent.receivers.count + 1) / 2;
    }else{
        if (self.replyList.count==0) {
            return 1;
        }else{
            ReplyGroupAgent *groupAgent = self.replyList[section];
            if (self.btnReplyToMe.selected) {
                return groupAgent.replygroup.count + 1;
            }else{
                return groupAgent.replygroup.count;
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _headView.tableView) {
        return 1;
    }else{
        NSInteger count = self.replyList.count;
        if (count == 0) {
            return 1;
        }
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _headView.tableView) {
        VEReceiversTableViewCell *cell = [VEReceiversTableViewCell cellWithTable:tableView];
        NSMutableArray *array = [NSMutableArray array];
        NSInteger index = 2 * indexPath.row;
        [array addObject:self.intelligAgent.receivers[index]];
        if (index + 1 < self.intelligAgent.receivers.count) {
            [array addObject:self.intelligAgent.receivers[index + 1]];
        }
        cell.receivers =array;
        return cell;
    }else{
        if (self.btnReplyToMe.selected && self.replyList.count == 0 && self.boxType == BoxTypeInput) {//暂无内容，回复
            VEReplyTableViewCell *cell = [VEReplyTableViewCell cellWithTableView:tableView index:VEReplyTableViewCellNoReplyMeReplyIndex identifier:KIdentifier_NoReplyMeReply];
            UIButton *btnMeReply = (UIButton *)[cell viewWithTag:kMeReplyBtnTag];
            [btnMeReply addTarget:self
                           action:@selector(commentItemTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else if(self.replyList.count == 0){//暂无内容，相关
            VEReplyTableViewCell *cell = [VEReplyTableViewCell cellWithTableView:tableView index:VEReplyTableViewCellNoReplyIndex identifier:KIdentifier_NoReply];
            return cell;
        }
        
        ReplyGroupAgent *groupAgent = self.replyList[indexPath.section];
        if (indexPath.row == groupAgent.replygroup.count) {//回复
            VEReplyTableViewCell *cell = [VEReplyTableViewCell cellWithTableView:tableView index:VEReplyTableViewCellReplyTipIndex identifier:KIdentifier_ReplyTip];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            return cell;
        }else{
            ReplyAgent *agent = groupAgent.replygroup[indexPath.row];
            //回复内容
            VEReplyTableViewCell *cell = [VEReplyTableViewCell cellWithTableview:tableView];
            if (indexPath.row == groupAgent.replygroup.count - 1 && self.boxType == BoxTypeRelativeMe) {
                cell.addBottomLine = YES;
            }else{
                cell.addBottomLine = NO;
            }
            cell.agent =  agent;
            
            return cell;
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _headView.tableView) {
        return  kTableCellReceiverHeight;
    }else{
        
        if (self.btnReplyToMe.selected && self.replyList.count == 0) {//暂无内容，回复
            return 100;
        }else if(self.btnReplyRelative.selected && self.replyList.count == 0){//暂无内容，相关
            return 100;
        }
        
        
        ReplyGroupAgent *groupAgent = self.replyList[indexPath.section];
        if (indexPath.row == groupAgent.replygroup.count) {
            return 30;
        }else{
            ReplyAgent *agent = groupAgent.replygroup[indexPath.row];
            CGFloat titleH = [agent.content boundingRectWithSize:CGSizeMake(Main_Screen_Width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]} context:nil].size.height;
            CGFloat heigth = 60 + titleH;
            return heigth;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _replyTableView) {
        return 10;
    }else{
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _replyTableView)
    {
        UIView *footerview = [[UIView alloc] init];
        footerview.backgroundColor = selectedBackgroundColor;
        return footerview;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _replyTableView){
        if (indexPath.section > (self.replyList.count - 1) || self.replyList.count == 0) {
            return;
        }
        ReplyGroupAgent *groupAgent = self.replyList[indexPath.section];
        if (indexPath.row == groupAgent.replygroup.count) {//回复
            [self commentItemToReceiverID:groupAgent.replyUserId
                           andReciverName:groupAgent.replyUserName];
        }
    }else{
        [self.headView showReceiver];
    }
}



#pragma SNVIew 代理
-(void)didFinishLoadWebView:(UIWebView *)webView contentHight:(CGFloat)contentHeight{
    CGRect frame = self.snView.frame;
    frame.size.height = contentHeight;
    self.snView.frame = frame;
    [self refreshContent];
}

-(void)reCalculateReplyTableSize{
    CGFloat replyTableHeight = 0.0f;
    NSArray *dataList = self.replyGroup.toMe;
    for (ReplyGroupAgent *groupAgent in dataList) {
        replyTableHeight += 40;
        for (ReplyAgent *agent in groupAgent.replygroup) {
            CGFloat titleH = [agent.content boundingRectWithSize:CGSizeMake(Main_Screen_Width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]} context:nil].size.height;
            CGFloat heigth = 60 + titleH;
            replyTableHeight +=heigth;
        }
    }
    if (replyTableHeight==0) {
        replyTableHeight = 100;
    }
    self.replyTableView.ve_height = replyTableHeight;
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.replyTableView.frame) + 64 + 60);
}


#pragma mark AriticleDetailTool代理
-(void)changeFontsize:(CGFloat)fontsize{
    [self.snView reload];
}

-(void)doDelete{
    MBProgressHUD *hud=[MBProgressHUD showMessage:@"正在删除，请稍后..."];
    [MessageTool deleteMessageWithAid:self.intelligAgent.articleId resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [MBProgressHUD changeToSuccessWithHUD:hud Message:@"删除成功"];
            if (self.deleteItem) {
                self.deleteItem(self.selectedIndex);
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [MBProgressHUD changeToErrorWithHUD:hud Message:@"删除失败，请重新删除"];
        }
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cateBtnHidden];
}

// 判别是否显示ToReplyBtn
- (void)dealWithShowingToReplyBtn
{
    if (self.scrollView.frame.size.height > self.replyTableView.contentSize.height)
    {
        self.toReplyBtn.hidden = YES;
    }
    else
    {
        self.toReplyBtn.hidden = NO;
    }
}

-(void)cateBtnHidden{
    if (self.scrollView.contentOffset.y > self.scrollView.bounds.size.height * 0.5){
        self.toTopBtn.hidden = NO;
    }else{
        self.toTopBtn.hidden = YES;
    }
    
    if (self.scrollView.contentOffset.y > (self.replyTableView.frame.origin.y - self.scrollView.bounds.size.height)){
        self.toReplyBtn.hidden = YES;
    }else{
        self.toReplyBtn.hidden = NO;
    }
}
@end

