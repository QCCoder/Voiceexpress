//
//  VEInformationDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-13.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEInformationDetailViewController.h"
#import "VEMessageDistributeViewController.h"
#import "DetailLabel.h"
#import "FrameAccessor.h"
#import "InformationReviewTool.h"
#import "ArticledetailTool.h"

@interface VEInformationDetailViewController ()<ArticleDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scorllView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIView *midView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) UILabel *detailLabel;
@property (nonatomic,weak) DetailLabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnUnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnForward;


@property (nonatomic, assign) BOOL                      firstTimeAppear;

@property (nonatomic, strong) UIActionSheet             *setfontActionSheet;
@property (nonatomic, strong) UIActionSheet             *optionActionSheet;
@property (nonatomic, strong) UIActionSheet             *shareActionSheet;


@end

@implementation VEInformationDetailViewController

-(DetailLabel *)contentLabel
{
    if (!_contentLabel) {
        DetailLabel *name = [[DetailLabel alloc]initWithFrame:CGRectMake(_titleLabel.ve_x, 0, 0, 0)];
        name.numberOfLines = 0;
        [self.scorllView addSubview:name];
        self.contentLabel = name;
    }
    return _contentLabel;
}

-(UILabel *)detailLabel
{
    if (!_detailLabel) {
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(_titleLabel.ve_x, 0, Main_Screen_Width - 2 * _titleLabel.ve_x, 17)];
        [name setFont:[UIFont boldSystemFontOfSize:14.0]];
        [name setNumberOfLines:0];
        [name setTextColor:RGBCOLOR(185, 185, 185)];
        [self.scorllView addSubview:name];
        self.detailLabel = name;
    }
    return _detailLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    _networkReportAgent.articleContent = @"正在加载数据，请稍后....";
    [self refreshContent];
    [self loadArticleContent];
}

- (void)setup
{
    self.title = self.config[Body];
    self.btnAccept.layer.cornerRadius = 4.0;
    self.btnUnAccept.layer.cornerRadius = 4.0;
    self.firstTimeAppear = YES;
    
    if (self.networkReportAgent.status != 1){
        self.btnForward.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"InformationDetail Disappear");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"InformationDetail Disappear");
    if (self.firstTimeAppear)
    {
        self.firstTimeAppear = NO;
        [self refreshContent];
    }
    
    _bottomView.ve_y = Main_Screen_Height - _bottomView.ve_height - 66;
    _midView.ve_y = _bottomView.ve_y - _midView.ve_height;
    _scorllView.ve_height = _midView.ve_y;
}


#pragma mark - My Methods

- (void)refreshContent
{
    _titleLabel.text = _networkReportAgent.title;
    NSString *detail = [NSString stringWithFormat:@"%@  %@  %@  %@", self.networkReportAgent.area, self.networkReportAgent.nickName, self.networkReportAgent.siteName, self.networkReportAgent.orgTime];
    self.detailLabel.text = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_networkReportAgent.statusString.length > 0) {
        [self refreshInterfaceWithStatus:_networkReportAgent.status];
        _stateLabel.text = _networkReportAgent.statusString;
        self.detailLabel.ve_y = CGRectGetMaxY(_stateLabel.frame) + 5;
    }else{
        self.detailLabel.ve_y = _stateLabel.ve_y;
        _stateLabel.hidden = YES;
    }
    
    CGFloat autorH = [self.detailLabel.text boundingRectWithSize:CGSizeMake(self.detailLabel.ve_width, self.detailLabel.font.lineHeight * 2) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.detailLabel.font} context:nil].size.height;
    self.detailLabel.ve_height = autorH;

    
    self.contentLabel.ve_y = CGRectGetMaxY(self.detailLabel.frame) + 15;
    self.contentLabel.text = _networkReportAgent.articleContent;
    
    CGFloat maxContentY = CGRectGetMaxY(self.contentLabel.frame) + 10;
    CGFloat maxScrollViewY = CGRectGetMaxY(self.scorllView.frame);
    CGFloat maxY = maxScrollViewY;
    if (maxContentY > maxScrollViewY ) {
        maxY = maxContentY;
    }
    
    _scorllView.contentSize = CGSizeMake(0, maxY + 1);
}

- (void)refreshInterfaceWithStatus:(NSInteger)status
{
    self.stateLabel.hidden = NO;
    self.btnAccept.hidden = NO;
    self.btnUnAccept.hidden = NO;
    
    if (status == 2){
        self.btnAccept.hidden = YES;
        self.btnUnAccept.ve_centerX = self.view.ve_width / 2;
        self.btnUnAccept.ve_centerY = _midView.ve_height / 2;
    }else if (status == 3){
        self.btnUnAccept.hidden = YES;
        self.btnAccept.ve_centerX = self.view.ve_width / 2;
        self.btnAccept.ve_centerY = _midView.ve_height / 2;
    }
}

- (void)loadArticleContent
{
    AriticledetailRequest *request = [[AriticledetailRequest alloc]init];
    request.aid = self.networkReportAgent.articleId;
    request.warnType = self.networkReportAgent.warnType;
    __weak typeof(self) weakSelf = self;
    [ArticledetailTool loadArticleContentWithRequest:request success:^(id JSON) {
        Articledetail *deatail = JSON;
        NSString *articleContent = @"内容加载失败，请稍后重试。";
        NSInteger result = deatail.result;
        if (result == 0) {
            articleContent = [DES3Util decrypt:deatail.content];
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
        weakSelf.networkReportAgent.articleContent = articleContent;
        [weakSelf refreshContent];
        
    } failure:^(NSError *error) {
        [PromptView hidePromptFromView:weakSelf.view];
        weakSelf.networkReportAgent.articleContent = @"内容加载失败，请稍后重试。";
        [weakSelf refreshContent];
        DLog(@"%@",[error localizedDescription]);
    }];
}

// type 1：录用  2：不录用
- (void)reviewArticleWithType:(NSInteger)type
{
    __weak typeof(self) weakSelf = self;
    [InformationReviewTool updateNetworkReportingReviewWithParam:@{@"aid":self.networkReportAgent.articleId,@"type":[NSString stringWithFormat:@"%ld",(long)type]} resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf successToSubmitReviewWithType:type];
        }
    }];
}

- (void)successToSubmitReviewWithType:(NSInteger)type
{
    // status: 1 待审核  2 已录用 3 未录用
    [AlertTool showAlertToolWithMessage:@"操作成功"];
    
    NSDate *today = [NSDate date];
    NSString *tmWarn = [[NSNumber numberWithLongLong:[today timeIntervalSince1970] *1000] stringValue];
    if (type == 1){  // 【录用】成功
        self.networkReportAgent.status = 2;
        self.networkReportAgent.statusString = @"已录用";
    }else if (type == 2){  // 【不录用】成功
        self.networkReportAgent.status = 3;
        self.networkReportAgent.statusString = @"未录用";
    }
    self.networkReportAgent.isChanged = YES;
    self.networkReportAgent.timeWarn  = tmWarn;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 监听事件

- (IBAction)reviewActionBtnTapped:(UIButton *)sender
{
    NSInteger type = 0;  // 1：录用  2：不录用
    if (sender == self.btnAccept){
        type = 1;
    }else if (sender == self.btnUnAccept){
        type= 2;
    }
    
    if (type != 0){
        [self reviewArticleWithType:type];
    }
}

- (IBAction)forward:(id)sender
{
    IntelligenceAgent *detailAgent = [ArticledetailTool getForward:self.networkReportAgent];
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc]init];
    distributeViewController.columnType             = IntelligenceColumnNone;
    distributeViewController.sendType               = SendTypeForwardFromInternet;
    distributeViewController.agent = detailAgent;
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

- (IBAction)showList:(id)sender
{
    ArticledetailTool *detailTool = [[ArticledetailTool alloc]init];
    detailTool.delegate = self;
    [detailTool showList:self agent:self.networkReportAgent];
}

#pragma mark - Notification

-(void)changeFontsize:(CGFloat)fontsize{
    self.contentLabel.font = [UIFont systemFontOfSize:fontsize];
    [self refreshContent];
}


@end
