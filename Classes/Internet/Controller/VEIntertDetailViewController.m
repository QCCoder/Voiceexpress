//
//  VEIntertDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-9-26.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEIntertDetailViewController.h"
#import "CTRichView.h"
#import "Agent.h"
#import "NetworkReportingAgent.h"
#import "ArticledetailTool.h"
#import "VEMessageDistributeViewController.h"
static const NSInteger kSetFontActionSheetTag   = 800;
extern BOOL LatestAlertHaveChanged;

@interface VEIntertDetailViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet CTRichView    *richContentView;
@property (strong, nonatomic)IBOutlet UIView       *headerView;
@property (strong, nonatomic) IBOutlet UIView *sndHeaderView;

@property (weak, nonatomic) IBOutlet UILabel       *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel       *labelInternetType;
@property (weak, nonatomic) IBOutlet UILabel       *labelTimePost;
@property (weak, nonatomic) IBOutlet UILabel       *labelAuthor;
@property (weak, nonatomic) IBOutlet UILabel       *labelDept;
@property (weak, nonatomic) IBOutlet UILabel *sndLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *sndLabelArea;
@property (weak, nonatomic) IBOutlet UILabel *sndLabelDetail;

@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic, strong) UIActionSheet             *setfontActionSheet;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *showListBtn;

@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestArticleLoader;
@property (nonatomic, assign) BOOL                      firstTimeAppear;

- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)showMoreList:(id)sender;

@end

@implementation VEIntertDetailViewController

@synthesize listDatas = _listDatas;

- (FYNHttpRequestLoader *)httpRequestArticleLoader
{
    if (_httpRequestArticleLoader == nil)
    {
        _httpRequestArticleLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestArticleLoader;
}

-(NSMutableArray *)listDatas
{
    if (_listDatas == nil)
    {
        _listDatas = [NSMutableArray array];
    }
    return _listDatas;
}

- (void)setListDatas:(NSMutableArray *)aArray
{
    if (aArray != self.listDatas)
    {
        [self.listDatas removeAllObjects];
        [self.listDatas addObjectsFromArray:aArray];
    }
}

- (void)dealloc
{
    @autoreleasepool {
        if (_listDatas)
        {
            [self.listDatas removeAllObjects];
            self.listDatas = nil;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    [self reloadImage];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)setUp
{
    self.firstTimeAppear = YES;
    self.promptView.layer.cornerRadius = 5.0;
    self.richContentView.fontSize = [VEUtility contentFontSize];
    self.title = self.config[Body];
}
-(void)reloadImage{
    [_showListBtn setImage:Image(Tab_Icon_More) forState:UIControlStateNormal];
    [_shareBtn setImage:Image(Icon_Share) forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.sndLabelTitle.ve_height = 65;
}

- (void)viewDidUnload
{
    [self setRichContentView:nil];
    [self setHeaderView:nil];
    [self setLabelTitle:nil];
    [self setLabelInternetType:nil];
    [self setLabelTimePost:nil];
    [self setLabelDept:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"InternetDeatil Appear");
    if (self.firstTimeAppear)
    {
        self.firstTimeAppear = NO;
        [self refreshContent];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"InternetDeatil Disappear");
    [self cancelAllHttpRequester];
}

- (void)cancelAllHttpRequester
{
    if (_httpRequestArticleLoader)
    {
        [self.httpRequestArticleLoader cancelAsynRequest];
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forward:(id)sender
{
    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
    {
        
        IntelligenceAgent *detailAgent = [ArticledetailTool getForward:self.listDatas[self.selectedRow]];
        VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc]init];
        distributeViewController.columnType             = IntelligenceColumnNone;
        distributeViewController.sendType               = SendTypeForwardFromInternet;
        distributeViewController.agent = detailAgent;
        [self.navigationController pushViewController:distributeViewController animated:YES];
    }
}

- (IBAction)showMoreList:(id)sender
{
   // if (self.setfontActionSheet == nil)
    {
        NSInteger curFontSize = [VEUtility contentFontSize];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"字体设置"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:
                                      (curFontSize == kSmallFontSize ? @"    小  √" : @"小"),
                                      (curFontSize == kMiddleFontSize ? @"    中  √" : @"中"),
                                      (curFontSize == kBigFontSize ? @"    大  √" : @"大"),
                                      (curFontSize == kSuperBigFontSize ? @"    特大  √" : @"特大"), nil];
        actionSheet.tag = kSetFontActionSheetTag;
        self.setfontActionSheet = actionSheet;
    }
    
    [self.setfontActionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kSetFontActionSheetTag)
    {
        NSInteger fontSize = 0;
        switch (buttonIndex)
        {
            case 0:
                fontSize = kSmallFontSize;
                break;
                
            case 1:
                fontSize = kMiddleFontSize;
                break;
                
            case 2:
                fontSize = kBigFontSize;
                break;
                
            case 3:
                fontSize = kSuperBigFontSize;
                break;
                
            default:
                break;
        }
        
        if (fontSize > 0)
        {
            [VEUtility setContentFontSize:fontSize];
            self.richContentView.fontSize = fontSize;
            [self.richContentView refreshContent];
        }
    }
}

#pragma mark - MyMethods

- (void)refreshContent
{
    @autoreleasepool {
        self.richContentView.ve_width = Main_Screen_Width;
        [self.richContentView scrollToTop];
        self.richContentView.ve_height = Main_Screen_Height - 108;
        if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
        {
            if (self.comeFrom == VEIntertDetailViewFromIntert)
            {
                [self refreshInternetContent];
            }
            else if (self.comeFrom == VEIntertDetailViewFromNetwork)
            {
                [self refreshNetworkContent];
            }
            else
            {
                return;
            }
            
            Agent *agent = [self.listDatas objectAtIndex:self.selectedRow];
            
            // 标记已读
            if (!agent.isRead)
            {
                agent.isRead = YES;
                LatestAlertHaveChanged = YES;
                [VEUtility setWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
            }
            
            // 加载文章内容详情
            NSString *content = nil;
            if (agent.articleContent)
            {
                content = agent.articleContent;
            }
            else
            {
                content = @"正在加载内容,请稍等...";
                [self loadArticleContentFromServer:agent];
            }
            
            [self updateArticleContent:content];
        }
    }
}

- (void)refreshInternetContent
{
    InternetAgent *internetAgent = [self.listDatas objectAtIndex:self.selectedRow];
    
    self.labelTitle.text = (internetAgent.title ? internetAgent.title : @"");
    
    self.labelInternetType.text = (internetAgent.internetType ? internetAgent.internetType : @"");
    self.labelAuthor.text = (internetAgent.author ? internetAgent.author : @"");
    self.labelDept.text = (internetAgent.internetDept ? internetAgent.internetDept : @"");
    self.labelTimePost.text = (internetAgent.timePost ? internetAgent.timePost : @"");
    
    if (self.labelInternetType.text.length == 0)
    {
        self.labelAuthor.left = self.labelInternetType.left;
        self.labelAuthor.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        self.labelAuthor.textAlignment = NSTextAlignmentCenter;
    }
    if (self.labelDept.text.length > 0)
    {
        self.headerView.ve_height = CGRectGetMaxY(self.labelTimePost.frame)+ 8.0f;
    }
    else
    {
        self.headerView.ve_height = CGRectGetMaxY(self.labelTimePost.frame) + 8.0f;
    }
    
    [self.headerView sizeToFit];
    self.richContentView.headerView = self.headerView;
}

- (void)refreshNetworkContent
{
    NetworkReportingAgent *networkAgent = [self.listDatas objectAtIndex:self.selectedRow];
    self.sndLabelTitle.text = networkAgent.title;
    self.sndLabelArea.text  = networkAgent.area;
    
    // 发帖昵称-发帖网站-发帖时间
    self.sndLabelDetail.ve_height = self.sndLabelArea.ve_height;
    NSString *detail = [NSString stringWithFormat:@"%@  %@  %@", networkAgent.nickName, networkAgent.siteName, networkAgent.orgTime];
    self.sndLabelDetail.text = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.sndLabelDetail sizeToFit];

    self.sndHeaderView.ve_height = CGRectGetMaxY(self.sndLabelDetail.frame) + 8.0f;
    [self.sndHeaderView sizeToFit];
    
    self.richContentView.headerView = self.sndHeaderView;
}

// 从服务器加载文章内容

- (void)loadArticleContentFromServer:(Agent *)agent
{
    NSString *stringUrl = [NSString stringWithFormat:@"%@/articledetail", kBaseURL];
    NSString *paramsStr;
    
    if (self.comeFrom == VEIntertDetailViewFromIntert) {
        paramsStr = [NSString stringWithFormat:@"aid=%@&uuid=%@&warnType=%ld&deviceInfo=IOS-%@", agent.articleId,_uuid, (long)agent.warnType, [VEUtility getUMSUDID]];
    }else{
        paramsStr = [NSString stringWithFormat:@"aid=%@&warnType=%ld&deviceInfo=IOS-%@", agent.articleId, (long)agent.warnType, [VEUtility getUMSUDID]];
    }
    
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [self showPromptWithTip:@"正在加载内容..."];
    
    [self.httpRequestArticleLoader cancelAsynRequest];
    [self.httpRequestArticleLoader startAsynRequestWithURL:url withParams:paramsStr];
    
    __weak typeof(self) weakSelf = self;
    [self.httpRequestArticleLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        [weakSelf stopShowPrompt];
        NSString *articleContent = @"内容加载失败，请稍后重试。";
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                NSString * stringTemp = [jsonParser retrieveContentValue];
                if (stringTemp != nil)
                {
                    articleContent = [DES3Util decrypt:stringTemp];
                    agent.articleContent = articleContent;
                }
            }
            else
            {
                [jsonParser printOutServerErrorMessage];
            }
        }
        else
        {
            DLog(@"articledetail, error: %@", error);
        }
        
        [weakSelf updateArticleContent:articleContent];
    }];
}

- (void)updateArticleContent:(NSString *)articleContent
{
    if (articleContent == nil)
    {
        articleContent = @"";
    }
    self.richContentView.content = articleContent;
}

- (void)showPromptWithTip:(NSString *)tip
{
    self.promptView.alpha = 0;
    self.labelTip.text = tip;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPrompt
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.labelTip.text = nil;
                     }
     ];
}


// 手势翻页

- (void)prevOrNextPage:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextPage];
        
    }
    else if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self prevPage];
        
    }
}

// 上一页

- (void)prevPage
{
    if (self.selectedRow > 0)
    {
        self.selectedRow--;
        [self refreshContent];
    }
    else
    {
        self.labelTip.text = @"已是第一页了";
        [self stopShowPrompt];
    }
}

// 下一页

- (void)nextPage
{
    if (self.selectedRow < (self.listDatas.count - 1))
    {
        self.selectedRow++;
        [self refreshContent];
    }
    else
    {
        self.labelTip.text = @"已是最后一页了";
        [self stopShowPrompt];
    }
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification
{
    if (self.setfontActionSheet)
    {
        if (self.setfontActionSheet.numberOfButtons)
        {
            [self.setfontActionSheet dismissWithClickedButtonIndex:(self.setfontActionSheet.numberOfButtons - 1)
                                                          animated:NO];
        }
    }
}

@end








