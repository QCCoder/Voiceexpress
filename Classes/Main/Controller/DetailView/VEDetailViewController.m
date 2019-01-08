//
//  VEDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEDetailViewController.h"
#import "VEOriginalViewController.h"
#import "VEAlertDistributeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "UIImageView+WebCache.h"
#import "CTRichView.h"
#import "RecommendReadTool.h"
#import "MessageTool.h"

static const NSInteger kOptionActionSheetTag    = 600;
static const NSInteger kShareActionSheetTag     = 700;
static const NSInteger kSetFontActionSheetTag   = 800;

extern BOOL bShouldRefreshImage;
extern BOOL LatestAlertHaveChanged;
extern BOOL kIsCurrentNetWorkWifi;

@interface VEDetailViewController ()<UIActionSheetDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *showListBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (strong, nonatomic)            IBOutlet UIView        *topView;
@property (weak, nonatomic) IBOutlet CTRichView    *textRichView;            // 信息内容
@property (weak, nonatomic) IBOutlet UIImageView   *levelImage;              // 预警等级
@property (weak, nonatomic) IBOutlet UILabel       *titleLabel;              // 标题
@property (weak, nonatomic) IBOutlet UILabel       *authorLabel;             // 作者名称
@property (weak, nonatomic) IBOutlet UILabel       *countsOfPicturelabel;    // 图片数量
@property (weak, nonatomic) IBOutlet UIImageView   *recommendPicView;        // 推荐阅读的图片
@property (weak, nonatomic) IBOutlet UILabel       *labelAreaTag;            // 地域标签

@property (weak, nonatomic) IBOutlet UIButton                  *btnItemFavorite;     // 收藏
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UIView                    *loadingActionView;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestArticleLoader;
@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestFavoriteLoader;
@property (nonatomic, strong) UIActionSheet             *optionActionSheet;
@property (nonatomic, strong) UIActionSheet             *shareActionSheet;
@property (nonatomic, strong) UIActionSheet             *setfontActionSheet;
@property (nonatomic, strong) NSArray                   *photos;
@property (nonatomic, assign) BOOL                      firstTimeAppear;
@property (nonatomic, assign) CGRect                    authorLabelOriginalRect;

- (IBAction)doForward:(id)sender;
- (IBAction)showList:(id)sender;
- (IBAction)doFavorite:(id)sender;
- (IBAction)back;

@end

@implementation VEDetailViewController

@synthesize listDatas = _listDatas;

- (FYNHttpRequestLoader *)httpRequestArticleLoader
{
    if (_httpRequestArticleLoader == nil)
    {
        _httpRequestArticleLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestArticleLoader;
}

- (FYNHttpRequestLoader *)httpRequestFavoriteLoader
{
    if (_httpRequestFavoriteLoader == nil)
    {
        _httpRequestFavoriteLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestFavoriteLoader;
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
        self.photos = nil;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
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

-(void)reloadImage{
    self.view.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
    [_showListBtn setImage:Image(Tab_Icon_More) forState:UIControlStateNormal];
    [_btnItemFavorite setImage:Image(Icon_Nofavourite) forState:UIControlStateNormal];
    [_shareBtn setImage:Image(Icon_Share) forState:UIControlStateNormal];
}

- (void)setUp
{
    self.title = @"正文";
    if (IOS7) {
        self.textRichView.height =self.view.height - 108 + 44 + 20;
    }else if([[[UIDevice currentDevice]systemVersion] floatValue] <9.0){
        self.textRichView.height =self.view.height -  44 ;
    }else{
        self.textRichView.height =Main_Screen_Height - 108;
    }
    self.firstTimeAppear = YES;
    self.loadingActionView.layer.cornerRadius = 5.0;
    
    self.textRichView.fontSize = [VEUtility contentFontSize];

    // 来自推荐阅读，可能有图片
    if (self.whichParent == VEDetailViewFromRecommendColumn ||
        self.whichParent == VEDetailViewFromFavoriteRecommend)
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recomImageViewTapped:)];
        [self.recommendPicView addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    self.photos = nil;
    self.listDatas = nil;
    self.mayDeleteFavoriteItems = nil;
    
    [self setTitleLabel:nil];
    [self setAuthorLabel:nil];
    [self setIndicator:nil];
    [self setLevelImage:nil];
    [self setLoadingActionView:nil];
    [self setBtnItemFavorite:nil];
    [self setRecommendPicView:nil];
    [self setCountsOfPicturelabel:nil];
    [self setLabelTip:nil];
    [self setTopView:nil];
    [self setTextRichView:nil];
    [self setLabelAreaTag:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (bShouldRefreshImage)
//    {
//        bShouldRefreshImage = NO;
//        [self refleshThumbImage];
//    }

    if (self.firstTimeAppear)
    {
        self.authorLabelOriginalRect = self.authorLabel.frame;
        self.firstTimeAppear = NO;
        [self refleshContent];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
}

- (void)cancelAllHttpRequester
{
    if (_httpRequestArticleLoader)
    {
        [self.httpRequestArticleLoader cancelAsynRequest];
    }
    if (_httpRequestFavoriteLoader)
    {
        [self.httpRequestFavoriteLoader cancelAsynRequest];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.authorLabel.numberOfLines = 0;
    self.authorLabel.ve_height = 40;
    self.authorLabel.ve_width = Main_Screen_Width - 40;
}

#pragma mark - My methods

// 刷新详情界面中的图片

- (void)refleshThumbImage
{
    // 来自【推荐阅读】,推荐阅读中可能有图片
    if (self.whichParent == VEDetailViewFromRecommendColumn ||
        self.whichParent == VEDetailViewFromFavoriteRecommend)
    {
        if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
        {
            RecommendAgent *recommendAgent = [self.listDatas objectAtIndex:self.selectedRow];
            if (recommendAgent.imageUrls.count)
            {
                NSString *stringURL = [recommendAgent.imageUrls objectAtIndex:0];
                [self.recommendPicView imageWithUrlStr:stringURL phImage:Image(Icon_Picture_Min)];
            }
        }
    }
}

// 刷新详情界面中的内容

- (void)refleshContent
{
    @autoreleasepool {
        [self.textRichView scrollToTop];
        
        if (self.whichParent == VEDetailViewFromLatestAlert ||
            self.whichParent == VEDetailViewFromSearchAlert ||
            self.whichParent == VEDetailViewFromFavoriteAlerts)
        {
            [self refleshWarnContent];
        }
        else if (self.whichParent == VEDetailViewFromRecommendColumn ||
                 self.whichParent == VEDetailViewFromFavoriteRecommend)
        {
            [self refleshRecommendReadContent];
        }
    }
}

// 最新预警、收藏中的预警、舆情搜索

- (void)refleshWarnContent
{
    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
    {
        WarnAgent *warnAgent = [self.listDatas objectAtIndex:self.selectedRow];
        
        // 标题
        self.titleLabel.text = (warnAgent.title ? warnAgent.title : @"");
        
        // 作者名称 - 站点 - 发文时间
        self.authorLabel.text = nil;
        self.authorLabel.frame = self.authorLabelOriginalRect;
        self.labelAreaTag.text = (warnAgent.localTag ? warnAgent.localTag : @"");
        
        NSString *author   = (warnAgent.author ? warnAgent.author : @"");
        NSString *site     = (warnAgent.site ? warnAgent.site : @"");
        NSString *timePost = (warnAgent.timePost ? warnAgent.timePost : @"");
        NSString *authorSite = [NSString stringWithFormat:@"%@  %@  %@", author, site, timePost];
        self.authorLabel.numberOfLines = 0;
        
        if (self.labelAreaTag.text.length <= 0)
        {
            self.labelAreaTag.text = [authorSite stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.labelAreaTag.textColor = self.authorLabel.textColor;
        }else{
            self.authorLabel.text = [authorSite stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
//        [self.authorLabel sizeToFit];
        
        // 预警等级 1:红色; 2:黄色; 3:蓝色; 其它为绿色.
        NSString *levelImageName = nil;
        switch (warnAgent.warnLevel)
        {
            case 1:
                levelImageName = self.config[Icon_List_Red];
                break;
                
            case 2:
                levelImageName = self.config[Icon_List_Yellow];
                break;
                
            case 3:
                levelImageName = self.config[Icon_List_Blue];
                break;
                
            default:
                levelImageName = self.config[Icon_List_Green];
                break;
        }
        self.levelImage.image = [QCZipImageTool imageNamed:levelImageName];
        
        // 收藏状态
        [self dealWithFavoriteState:warnAgent.articleId andWarnType:warnAgent.warnType];
        
        // 已读、未读状态
        [self dealWithReadState:warnAgent];
        
        // 无图片
        self.recommendPicView.image = nil;
        self.recommendPicView.hidden = YES;
        self.countsOfPicturelabel.text = nil;
        self.countsOfPicturelabel.hidden = YES;
        self.topView.frame = CGRectMake(0, 0,
                                        Main_Screen_Width,
                                        (self.authorLabel.frame.origin.y + self.authorLabel.frame.size.height + 5.0f));
//        [self.topView setBackgroundColor:[UIColor redColor]];
//        NSLog(@"%@",NSStringFromCGRect(self.topView.frame));
        // header View
        self.textRichView.headerView = self.topView;
//        self.textRichView.backgroundColor = [UIColor blueColor];
        // 文章内容
        [self showArticleContent:warnAgent];
    }
}

// 推荐阅读、收藏中的推荐阅读

- (void)refleshRecommendReadContent
{
     if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
     {
         RecommendAgent *recommendAgent = [self.listDatas objectAtIndex:self.selectedRow];
         
         // 标题
         self.titleLabel.text = (recommendAgent.title ? recommendAgent.title : @"");
         
         self.authorLabel.frame = self.labelAreaTag.frame;
         self.labelAreaTag.hidden = YES;
         
         // 发文时间
         self.authorLabel.text = (recommendAgent.timePost ? recommendAgent.timePost : @"");
         
         // 收藏状态
         [self dealWithFavoriteState:recommendAgent.articleId andWarnType:recommendAgent.warnType];
         
         // 已读、未读状态
         [self dealWithReadState:recommendAgent];
         
         // 处理有无图片
         self.recommendPicView.image = nil;
         self.recommendPicView.hidden = YES;
         self.countsOfPicturelabel.text = nil;
         self.countsOfPicturelabel.hidden = YES;
         
         if (recommendAgent.imageUrls.count > 0)
         {
             self.recommendPicView.hidden = NO;
             self.countsOfPicturelabel.hidden = NO;
             
             if (!kIsCurrentNetWorkWifi &&
                 [VEUtility shouldReceivePictureOnCellNetwork])
             {
                 // 当前网络是WWAN, 并且在2G/3G网络下不允许自动接收图片
                 self.recommendPicView.frame = CGRectMake(120, self.recommendPicView.frame.origin.y, 80, 60);
                 self.recommendPicView.image = Image(Icon_Picture_Min);
             }
             else
             {
                 // 当前网络是wifi,或者在2G/3G网络下允许自动接收图片
                 self.recommendPicView.frame = CGRectMake(20, self.recommendPicView.frame.origin.y, 280, 210);
                 
                 NSString *stringURL = [recommendAgent.imageUrls objectAtIndex:0][@"imageUrl"];
                 
                 [self.recommendPicView imageWithUrlStr:stringURL phImage:Image(Icon_Picture_Min)];
             }
             
             self.countsOfPicturelabel.frame = CGRectMake(self.countsOfPicturelabel.frame.origin.x,
                                                          (self.recommendPicView.frame.origin.y + self.recommendPicView.frame.size.height + 4.0f),
                                                          self.countsOfPicturelabel.frame.size.width,
                                                          self.countsOfPicturelabel.frame.size.height);
             
             self.countsOfPicturelabel.text = [NSString stringWithFormat:@"点击查看（共%ld张）", (unsigned long)recommendAgent.imageUrls.count];
             
             self.topView.frame = CGRectMake(0, 0,
                                             self.topView.frame.size.width,
                                             (self.countsOfPicturelabel.frame.origin.y + self.countsOfPicturelabel.frame.size.height + 5.0f));
         }
         else
         {
             self.topView.frame = CGRectMake(0, 0,
                                             self.topView.frame.size.width,
                                             (self.authorLabel.frame.origin.y + self.authorLabel.frame.size.height + 5.0f));
         }
         
         // header View
         self.textRichView.headerView = self.topView;
         
         // 文章内容
         [self showArticleContent:recommendAgent];
     }
}

// 显示文章内容

- (void)showArticleContent:(Agent *)agent
{
    NSString *content = nil;
    if (agent.articleContent)
    {
        content = agent.articleContent;
    }
    else
    {
        NSString *articleContent = [VEUtility retrieveWarnContentWithArticleID:agent.articleId
                                                                   andWarnType:agent.warnType];
        if (articleContent == nil)
        {
            content = @"正在加载内容,请稍等...";
            [self loadArticleContentFromServer:agent];
        }
        else
        {
            agent.articleContent = articleContent;
            content = articleContent;
        }
    }
    
    [self updateArticleContent:content];
}

- (void)updateArticleContent:(NSString *)articleContent
{
    if (articleContent == nil)
    {
        articleContent = @"";
    }
    self.textRichView.content = articleContent;
}

// 从服务器加载文章内容

- (void)loadArticleContentFromServer:(Agent *)agent
{
    NSString *stringUrl = [NSString stringWithFormat:@"%@/articledetail", kBaseURL];
    NSString *paramsStr = [NSString stringWithFormat:@"aid=%@&warnType=%ld&deviceInfo=IOS-%@", agent.articleId, (long)agent.warnType, [VEUtility getUMSUDID]];
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
                    articleContent = stringTemp;
                    agent.articleContent = articleContent;
                    [VEUtility setWarnArticleContent:articleContent
                                       withArticleID:agent.articleId
                                         andWarnType:agent.warnType];
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

// 已读、未读状态

- (void)dealWithReadState:(Agent *)agent
{
    if (!agent.isRead)
    {
        agent.isRead = YES;
        if (self.whichParent == VEDetailViewFromLatestAlert)
        {
            LatestAlertHaveChanged = YES;
            [VEUtility setWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
        }
        else if (self.whichParent == VEDetailViewFromRecommendColumn)
        {
            [RecommendReadTool setRecommendReadInColumn:self.columnID withArticleId:agent.articleId andWarnType:agent.warnType];
        }
    }
}

// 收藏状态

- (void)dealWithFavoriteState:(NSString *)articleId andWarnType:(NSInteger)warnType
{
    if (self.whichParent == VEDetailViewFromFavoriteRecommend ||
        self.whichParent == VEDetailViewFromFavoriteAlerts )
    {
        NSInteger tag = 10;
        NSString *imgName = self.config[Icon_Favourite];
        BOOL bIsAlreadyThere = NO;
        for (NSNumber *mayDeleteFavorite in self.mayDeleteFavoriteItems)
        {
            if (mayDeleteFavorite.integerValue == self.selectedRow)
            {
                bIsAlreadyThere = YES;
                break;
            }
        }
        if (bIsAlreadyThere)
        {
            imgName = self.config[Icon_Favourite];
            tag = 11;
        }

        [self.btnItemFavorite setImage:[QCZipImageTool imageNamed:imgName] forState:UIControlStateNormal];
        self.btnItemFavorite.tag = tag;
    }
    else if (self.whichParent == VEDetailViewFromLatestAlert ||
             self.whichParent == VEDetailViewFromSearchAlert ||
             self.whichParent == VEDetailViewFromRecommendColumn)
    {
        [self.btnItemFavorite setImage:[QCZipImageTool imageNamed:self.config[Icon_Favourite]] forState:UIControlStateNormal];
        self.btnItemFavorite.tag = 11;
        
        NSString *stringUrl = [NSString stringWithFormat:@"%@/WarnFavoritesState", kBaseURL];
        NSString *paramsStr = [NSString stringWithFormat:@"aid=%@&warnType=%ld", articleId, (long)warnType];
        NSURL *url = [NSURL URLWithString:stringUrl];
        
        [self.httpRequestFavoriteLoader cancelAsynRequest];
        [self.httpRequestFavoriteLoader startAsynRequestWithURL:url withParams:paramsStr];
        
        __weak typeof(self) weakSelf = self;
        [self.httpRequestFavoriteLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
            
            if (resultData != nil)
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
                if ([jsonParser retrieveRusultValue] == 0 &&
                    [jsonParser retrieveFavoriteStateValue])
                {
                    [weakSelf.btnItemFavorite setImage:[QCZipImageTool imageNamed:weakSelf.config[Icon_Favourite]] forState:UIControlStateNormal];
                    weakSelf.btnItemFavorite.tag = 10;
                }
            }
        }];
    }
}

- (void)showPromptWithTip:(NSString *)tip
{
    self.loadingActionView.alpha = 0;
    self.labelTip.text = tip;
    [UIView animateWithDuration:1.0 animations:^{
        self.loadingActionView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPrompt
{
    self.loadingActionView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.loadingActionView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.labelTip.text = nil;
                     }
     ];
}

// 将信息进行分享, 三种方式: 邮件、短消息、复制

- (void)doShare
{
    if (self.shareActionSheet == nil)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"邮件", @"短信", nil];
        actionSheet.tag = kShareActionSheetTag;
        self.shareActionSheet = actionSheet;
    }
    
    [self.shareActionSheet showInView:self.view];
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
        [self refleshContent];
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
        [self refleshContent];
    }
    else
    {
        self.labelTip.text = @"已是最后一页了";
        [self stopShowPrompt];
    }
}

// 打开原文

- (void)originalWebAction
{
    if (self.whichParent == VEDetailViewFromLatestAlert ||
        self.whichParent == VEDetailViewFromSearchAlert ||
        self.whichParent == VEDetailViewFromFavoriteAlerts)
    {
        if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
        {
            WarnAgent *warnAgent = [self.listDatas objectAtIndex:self.selectedRow];
            VEOriginalViewController *originalViewController = [[VEOriginalViewController alloc]
                                                                initWithNibName:@"VEOriginalViewController" bundle:nil];
            originalViewController.originalUrl = warnAgent.url;
            
            [self.navigationController pushViewController:originalViewController animated:YES];
        }
    }
}

- (void)doSettingFontSize
{
    //if (self.setfontActionSheet == nil)
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


#pragma mark - Gesture Action

// 浏览推荐阅读中的图片

- (void)recomImageViewTapped:(UITapGestureRecognizer *)sender
{
//    if (self.whichParent == VEDetailViewFromRecommendColumn ||
//        self.whichParent == VEDetailViewFromFavoriteRecommend)
//    {
//        if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
//        {
//            RecommendAgent *recommendAgent = [self.listDatas objectAtIndex:self.selectedRow];
//            if (recommendAgent.imageUrls.count > 0)
//            {
//                NSMutableArray *photoList = [[NSMutableArray alloc] initWithCapacity:recommendAgent.imageUrls.count];
//                for (NSString *imageUrl in recommendAgent.imageUrls)
//                {
//                    [photoList addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]]];
//                }
//                self.photos = photoList;
//                
//                // Create browser
//                MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//                browser.displayActionButton = YES;
//                
//                // Modal
//                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
//                nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
//                {
//                    [self presentViewController:nc animated:YES completion:NULL];
//                }
//
//            }
//        }
//    }
//    bShouldRefreshImage = NO;
}

// 分享的内容: 标题、作者、时间、内容、原文链接

- (NSString *)retrieveShareContent
{
    NSString *shareContent = @"";
    
    // 标题
    if (self.titleLabel.text.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"标题：%@\n", self.titleLabel.text];
    }
    
    NSString *stringUrl = nil;
    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
    {
        Agent *agent = [self.listDatas objectAtIndex:self.selectedRow];
        
        // 作者
        if ([agent respondsToSelector:@selector(author)])
        {
            NSString *author = [agent performSelector:@selector(author)];
            if (author.length > 0)
            {
                shareContent = [shareContent stringByAppendingFormat:@"作者：%@\n", author];
            }
        }
        
        // 来源
        if ([agent respondsToSelector:@selector(site)])
        {
            NSString *site = [agent performSelector:@selector(site)];
            if (site.length > 0)
            {
                shareContent = [shareContent stringByAppendingFormat:@"来源：%@\n", site];
            }
        }
        
        // 发文时间
        if (agent.timePost.length > 0)
        {
            shareContent = [shareContent stringByAppendingFormat:@"发文时间：%@\n", agent.timePost];
        }

        // 原文链接
        if ([agent respondsToSelector:@selector(url)])
        {
            stringUrl = [agent performSelector:@selector(url)];
        }
    }
    
    // 内容
    if (self.textRichView.content.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"内容：%@\n", self.textRichView.content];
    }
    
    // 原文链接
    if (stringUrl.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"原文链接：%@\n", stringUrl];
    }
    
    return shareContent;
}

- (void)doShareViaMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        [mailViewController setToRecipients:nil];
        [mailViewController setMessageBody:[self retrieveShareContent] isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:NULL];
    }
    else
    {
        DLog(@"当前设备不支持发送邮件");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"当前设备不支持发送邮件"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

- (void)doShareViaMessage
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.messageComposeDelegate = self;
        [messageVC setBody:[self retrieveShareContent]];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            [self presentViewController:messageVC animated:YES completion:NULL];
        }
    }
    else
    {
        DLog(@"当前设备不支持发送短信");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"当前设备不支持发送短信"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)doShareViaCopy
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self retrieveShareContent];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"内容拷贝成功\n您可在短信或邮件中粘贴发送"
                                                   delegate:nil
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    [alert show];
    
}

#pragma mark - IBAction

// 添加或取消文章收藏

- (IBAction)doFavorite:(id)sender
{
    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
    {
        // 10 : 已被收藏
        // 11 : 未被收藏
        NSInteger tag = self.btnItemFavorite.tag;
        NSString *action = nil;
        if (tag == 10)
        {
            action = @"WarnFavoritesRemove";
        }
        else
        {
            action = @"WarnFavoritesAdd";
        }

        Agent *agent = [self.listDatas objectAtIndex:self.selectedRow];
        
        NSString *stringUrl = [NSString stringWithFormat:@"%@/%@", kBaseURL, action];
        NSString *paramsStr = [NSString stringWithFormat:@"aid=%@&warnType=%ld", agent.articleId, (long)agent.warnType];
        NSURL *url = [NSURL URLWithString:stringUrl];
        
        [self.httpRequestFavoriteLoader cancelAsynRequest];
        [self.httpRequestFavoriteLoader startAsynRequestWithURL:url withParams:paramsStr];
        
        __weak typeof(self) weakSelf = self;
        [self.httpRequestFavoriteLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
            
            if (error != nil)
            {
                [VEUtility showServerErrorMeassage:error];
            }
            
            if (resultData != nil)
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
                if ([jsonParser retrieveRusultValue] == 0)
                {
                    [weakSelf updateFavoriteStateFromOldState:tag];
                }
                else
                {
                    [jsonParser reportErrorMessage];
                }
            }
        }];
    }
}

- (void)updateFavoriteStateFromOldState:(NSInteger)oldState
{
    // 10 : 已被收藏
    // 11 : 未被收藏
    if (oldState == 10)
    {
        [self.btnItemFavorite setImage:[QCZipImageTool imageNamed:self.config[Icon_Nofavourite]] forState:UIControlStateNormal];
        self.btnItemFavorite.tag = 11;
        self.labelTip.text = @"取消收藏成功";
    }
    else
    {
        [self.btnItemFavorite setImage:[QCZipImageTool imageNamed:self.config[Icon_Favourite]] forState:UIControlStateNormal];
        self.btnItemFavorite.tag = 10;
        self.labelTip.text = @"添加收藏成功";
        
    }
    [self stopShowPrompt];
    
    
    // 来自收藏夹
    if (self.whichParent == VEDetailViewFromFavoriteAlerts ||
        self.whichParent == VEDetailViewFromFavoriteRecommend )
    {
        if (self.btnItemFavorite.tag == 11)
        {
            BOOL bIsAlreadyThere = NO;
            for (NSNumber *deleteItem in self.mayDeleteFavoriteItems)
            {
                if (deleteItem.integerValue == self.selectedRow)
                {
                    bIsAlreadyThere = YES;
                    break;
                }
            }
            if (bIsAlreadyThere == NO)
            {
                [self.mayDeleteFavoriteItems addObject:[NSNumber numberWithInteger:self.selectedRow]];
            }
        }
        else  // 先取消了收藏，后又添加了收藏
        {
            NSNumber *shouldRemoveObject = nil;
            for (NSNumber *deleteItem in self.mayDeleteFavoriteItems)
            {
                if (deleteItem.integerValue == self.selectedRow)
                {
                    shouldRemoveObject = deleteItem;
                    break;
                }
            }
            if (shouldRemoveObject != nil)
            {
                [self.mayDeleteFavoriteItems removeObject:shouldRemoveObject];
            }
        }
    }
}

// 转发
- (IBAction)doForward:(id)sender
{
//    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
//    {
//        Agent *agent = [self.listDatas objectAtIndex:self.selectedRow];
//            
//        VEAlertDistributeViewController *distributeViewController = [[VEAlertDistributeViewController alloc] initWithNibName:@"VEAlertDistributeViewController" bundle:nil];
//        
//        distributeViewController.columnType = IntelligenceColumnNone;
//        
//        if (self.whichParent == VEDetailViewFromFavoriteRecommend ||
//            self.whichParent == VEDetailViewFromRecommendColumn)
//        {
//            distributeViewController.sendType = SendTypeForwardFromRecommendRead;
//        }
//        else
//        {
//            distributeViewController.sendType = SendTypeForwardFromWarnAlert;
//        }
//        
//        distributeViewController.forwardArticleContent  = self.textRichView.content;
//        distributeViewController.forwardAgent           = agent;
//        distributeViewController.forwardFromType        = ForwardFromWarnAlert;
//        
//        [self.navigationController pushViewController:distributeViewController animated:YES];
//        
//    }
}

- (IBAction)showList:(id)sender
{
    if (self.selectedRow >= 0 && self.selectedRow < self.listDatas.count)
    {
        UIActionSheet *actionSheet = nil;
        Agent *agent = [self.listDatas objectAtIndex:self.selectedRow];
        if ([agent isKindOfClass:[WarnAgent class]])
        {
            WarnAgent *warnAgent = (WarnAgent *)agent;
            if (warnAgent.url.length)
            {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"分享", @"复制", @"查看原文", @"字体设置", nil];
            }
        }
        
        if (actionSheet == nil)
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"分享", @"复制", @"字体设置", nil];
        }
        
        actionSheet.tag = kOptionActionSheetTag;
        self.optionActionSheet = actionSheet;
        [self.optionActionSheet  showInView:self.view];
    }
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kOptionActionSheetTag)
    {
        if (buttonIndex == 0)
        {
            [self doShare];
        }
        else if (buttonIndex == 1)
        {
            [self doShareViaCopy];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"字体设置"])
        {
            [self doSettingFontSize];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"查看原文"])
        {
            [self originalWebAction];
        }
    }
    else if (actionSheet.tag == kShareActionSheetTag)
    {
        if (0 == buttonIndex)
        {
            [self doShareViaMail];
        }
        else if (1 == buttonIndex)
        {
            [self doShareViaMessage];
        }
    }
    else if (actionSheet.tag == kSetFontActionSheetTag)
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
            self.textRichView.fontSize = fontSize;
            [self.textRichView refreshContent];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"邮件已发出"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification
{
    if (self.optionActionSheet)
    {
        if (self.optionActionSheet.numberOfButtons)
        {
            [self.optionActionSheet dismissWithClickedButtonIndex:(self.optionActionSheet.numberOfButtons - 1)
                                                         animated:NO];
        }
    }
    
    if (self.shareActionSheet)
    {
        if (self.shareActionSheet.numberOfButtons)
        {
            [self.shareActionSheet dismissWithClickedButtonIndex:(self.shareActionSheet.numberOfButtons - 1)
                                                         animated:NO];
        }
    }
    
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
















