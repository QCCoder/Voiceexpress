//
//  VEIntertDetailController.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEIntertDetailController.h"
#import "UrlModel.h"
#import "SNScrollView.h"
#import "VEInternetTool.h"
#import "NetworkReportingAgent.h"
#import "ArticledetailTool.h"
#import "VEMessageDistributeViewController.h"
@interface VEIntertDetailController ()<SNScrollViewDelegate,ArticleDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *netWorkView;
@property (nonatomic,weak) UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *toolBar;


@property (weak, nonatomic) IBOutlet UIView *inertnetView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *autorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deptLabel;

//WebView显示内容
@property (nonatomic,weak  ) SNScrollView       *snView;
@property (nonatomic,strong) NetworkReportingAgent *networkAgent;
@property (nonatomic,strong) InternetAgent *internetAgent;

@end

@implementation VEIntertDetailController

-(SNScrollView *)snView
{
    if (!_snView) {
        SNScrollView *sv = [[SNScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame) - 10, Main_Screen_Width, 50)];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"正文";
    self.view.backgroundColor = [UIColor whiteColor];
    self.toolBar.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
    self.scrollView.alwaysBounceVertical = YES;
    if (_comeFrom == VEIntertDetailViewFromIntert) {
        _internetAgent = (InternetAgent *)_agent;
        [self setupInternet];//区县上报
    }else{
        _networkAgent = (NetworkReportingAgent *)_agent;
        [self setupNewWotk];
    }
    [self loadInternetData];
}


-(void)setupInternet{
    _netWorkView.hidden = YES;
    _inertnetView.hidden = NO;
    
    _titleLabel.text = _internetAgent.title;
    _typeLabel.text = _internetAgent.internetType;
    _autorLabel.text = _internetAgent.author;
    _timeLabel.text = _internetAgent.timePost;
    _deptLabel.text = _internetAgent.internetDept;
    _titleLabel.ve_size = [_titleLabel.text boundingRectWithSize:CGSizeMake(Main_Screen_Width - 24, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size;
    CGFloat typeY = CGRectGetMaxY(_titleLabel.frame);
    _timeLabel.ve_y = _autorLabel.ve_y = _typeLabel.ve_y = typeY;
    _deptLabel.ve_y = CGRectGetMaxY(_typeLabel.frame);
    _inertnetView.ve_height = CGRectGetMaxY(_deptLabel.frame);
    _headView = _inertnetView;
}

-(void)setupNewWotk{
    _inertnetView.hidden = YES;
    
    _netWorkView.hidden = NO;
    
    _nTitleLabel.text = _networkAgent.title;
    
    _nTitleLabel.ve_size = [_networkAgent.title boundingRectWithSize:CGSizeMake(Main_Screen_Width - 24, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_nTitleLabel.font} context:nil].size;
    
    _areaLabel.text = _networkAgent.area;
    _infoLabel.text = [NSString stringWithFormat:@"%@  %@  %@", _networkAgent.nickName, _networkAgent.siteName, _networkAgent.orgTime];
    
    _areaLabel.ve_y = CGRectGetMaxY(_nTitleLabel.frame) + 2;
    _infoLabel.ve_y = CGRectGetMaxY(_areaLabel.frame) + 2;
    _infoLabel.ve_size = [_infoLabel.text boundingRectWithSize:CGSizeMake(Main_Screen_Width - 24, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_infoLabel.font} context:nil].size;
    
    
    _netWorkView.ve_height = CGRectGetMaxY(_infoLabel.frame);
    _headView = _netWorkView;
}

-(void)loadInternetData{
    NSString *deviceInfo = [NSString stringWithFormat:@"IOS-%@",[VEUtility getUMSUDID]];
    NSString *uuid = _internetAgent.uuid;
    if (!uuid) {
        uuid = @"0";
    }
    NSDictionary *dict = @{
                           @"aid" : _agent.articleId,
                           @"uuid" : uuid,
                           @"warnType":[NSString stringWithFormat:@"%ld",_agent.warnType],
                           @"deviceInfo":deviceInfo
                           };
    
    [PromptView startShowPromptViewWithTip:@"正在加载内容..." view:self.view];
    [VEInternetTool loadArticleContentWithParamters:dict success:^(id JSON) {
        [PromptView hidePromptFromView:self.view];
        Articledetail *detail = JSON;
        _agent.articleContent = [DES3Util decrypt:detail.content];
        [self loadWebView];
    } failure:^(NSError *error) {
        [PromptView hidePromptFromView:self.view];
    }];
}

-(void)loadWebView{
    if (self.agent.articleContent.length == 0) {
        return;
    }
    NSString *showContent = [self.agent.articleContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    showContent = [showContent stringByReplacingOccurrencesOfString:@"　" withString:@""];
    showContent = [showContent stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
    showContent = [showContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    showContent = [UrlModel urlContent:[showContent lowercaseString]];
    [self.snView showcontentWithModelString:showContent];
}

#pragma SNVIew 代理
-(void)didFinishLoadWebView:(UIWebView *)webView contentHight:(CGFloat)contentHeight{
    CGRect frame = self.snView.frame;
    frame.size.height = contentHeight;
    self.snView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(Main_Screen_Width, CGRectGetMaxY(self.snView.frame));
}

- (IBAction)showList:(id)sender {
    ArticledetailTool *detailTool = [[ArticledetailTool alloc]init];
    detailTool.delegate = self;
    [detailTool showList:self agent:_agent];
}

- (IBAction)doForward:(id)sender {
    IntelligenceAgent *detailAgent = [ArticledetailTool getForward:_agent];
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc]init];
    distributeViewController.columnType             = IntelligenceColumnNone;
    distributeViewController.sendType               = SendTypeForwardFromInternet;
    distributeViewController.agent = detailAgent;
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

#pragma mark 代理方法
-(void)changeFontsize:(CGFloat)fontsize{
    [self.snView reload];
}

@end
