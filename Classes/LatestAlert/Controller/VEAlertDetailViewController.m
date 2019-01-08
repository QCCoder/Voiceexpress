//
//  VEAlertDetailViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEAlertDetailViewController.h"
#import "VEMessageDistributeViewController.h"
#import "ArticledetailTool.h"
#import "DetailLabel.h"
#import "RecommendReadTool.H"
@interface VEAlertDetailViewController ()<ArticleDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) UILabel *areaLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) DetailLabel *contentLabel;
@end

@implementation VEAlertDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadImage];
    [self setup];
    [self loadContent];
    [self loadWarnFavoritesState];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"AlertDetail Disappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"AlertDetail Disappear");
}

-(void)reloadImage{
    [_favoriteBtn setImage:Image(Icon_Favourite) forState:UIControlStateNormal];
    [_favoriteBtn setImage:Image(Icon_Nofavourite) forState:UIControlStateSelected];
}

-(void)setup{
    self.title = @"正文";
    self.footView.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
    _scrollView.alwaysBounceVertical = YES;
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 5, Main_Screen_Width - 32, 56)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    _titleLabel.textColor = RGBCOLOR(4, 4, 4);
    _titleLabel.numberOfLines = 2;
    _titleLabel.text = _agent.title;
    [self.scrollView addSubview:_titleLabel];
    _areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 60, Main_Screen_Width - 32, 18)];
    _areaLabel.textColor = RGBCOLOR(26, 131, 255);
    _areaLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _areaLabel.text = self.agent.localTag;
    [self.scrollView addSubview:_areaLabel];
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(_areaLabel.frame) + 5, Main_Screen_Width - 32, 0)];
    _timeLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _timeLabel.textColor = RGBCOLOR(185, 185, 185);
    _timeLabel.numberOfLines = 0;
    NSString *author   = (_agent.author ? [NSString stringWithFormat:@"%@ ",_agent.author] : @"");
    NSString *site     = (_agent.site ? [NSString stringWithFormat:@"%@ ",_agent.site]: @"");
    NSString *timePost = (_agent.timePost ? [NSString stringWithFormat:@"%@ ",_agent.timePost] : @"");
    NSString *authorSite = [NSString stringWithFormat:@"%@%@%@", author, site, timePost];
    _timeLabel.text = authorSite;
    _timeLabel.ve_height = [authorSite boundingRectWithSize:CGSizeMake(Main_Screen_Width-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_timeLabel.font} context:nil].size.height;
    [self.scrollView addSubview:_timeLabel];
    
    if (_areaLabel.text.length == 0) {
        _timeLabel.ve_y = 66;
    }
    
    NSString *levelImageName = nil;
    switch (_agent.warnLevel)
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
    self.listView.image = [QCZipImageTool imageNamed:levelImageName];
    
    
    _contentLabel = [[DetailLabel alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(_timeLabel.frame) + 10, Main_Screen_Width - 32, 0)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:[VEUtility contentFontSize]];
    [self.scrollView addSubview:_contentLabel];
}
-(void)setupContent{
    _contentLabel.text = _agent.articleContent;
    
    _contentLabel.ve_height = [_contentLabel.text boundingRectWithSize:CGSizeMake(Main_Screen_Width - 32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel.font} context:nil].size.height;
    
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_contentLabel.frame) + 44);
}

-(void)loadContent{
    AriticledetailRequest *request = [[AriticledetailRequest alloc]init];
    request.aid = _agent.articleId;
    request.warnType = _agent.warnType;
    [PromptView startShowPromptViewWithTip:@"正在加载数据，请稍等..." view:self.view];
    [ArticledetailTool loadArticleContentWithRequest:request success:^(id JSON) {
        [PromptView hidePromptFromView:self.view];
        Articledetail *detail = JSON;
        _agent.articleContent = detail.content;
        [self setupContent];
    } failure:^(NSError *error) {
        [PromptView hidePromptFromView:self.view];
        DLog(@"%@",[error localizedDescription]);
    }];
}

-(void)loadWarnFavoritesState
{
    AriticledetailRequest *request = [[AriticledetailRequest alloc]init];
    request.aid = _agent.articleId;
    request.warnType = _agent.warnType;
    [ArticledetailTool loadWarnFavoriteWithRequest:request Result:^(id JSON, NSInteger result, NSString *msg) {
        if (result == HTTPERROR) {
            DLog(@"%@",msg);
            [AlertTool showAlertToolWithMessage:msg];
        }else if (result == 0){
            _favoriteBtn.selected = ![JSON boolValue];
            
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
    }];
}

-(void)updateFavoriteStateFromOldState:(BOOL)isFavorite{
    // 10 : 已被收藏
    // 11 : 未被收藏
    NSString *msg = @"";
    if (!isFavorite) {
        msg = @"添加收藏成功";
    }else{
        msg = @"取消收藏成功";
    }
    [AlertTool showAlertToolWithMessage:msg];
}

/**
 *  点击收藏
 */
- (IBAction)doFavorite:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    BOOL isFavorite = btn.selected;
    
    NSString *url = nil;
    if (!isFavorite) {
        url = @"WarnFavoritesAdd";
    }else{
        url = @"WarnFavoritesRemove";
    }
    
    __weak typeof(self) weakSelf = self;
    [RecommendReadTool doFavoriteWithUrl:url param:@{@"aid":_agent.articleId, @"warnType":[NSString stringWithFormat:@"%ld",(long)_agent.warnType]} success:^(id JSON) {
        NSInteger result = [JSON[@"result"] integerValue];
        if (result == 0) {
            [weakSelf updateFavoriteStateFromOldState:isFavorite];
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
    } failure:^(NSError *error) {
        DLog(@"%@",[error localizedDescription]);
    }];
}

/**
 *  转发
 */
- (IBAction)doForward:(id)sender {
    IntelligenceAgent *detailAgent = [ArticledetailTool getForward:_agent];
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc]init];
    distributeViewController.columnType             = IntelligenceColumnNone;
    distributeViewController.sendType               = SendTypeForwardFromWarnAlert;
    distributeViewController.agent = detailAgent;
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

- (IBAction)showList:(id)sender {
    ArticledetailTool *detailTool = [[ArticledetailTool alloc]init];
    detailTool.delegate = self;
    [detailTool showWithOrgList:self agent:_agent];
}

#pragma mark 代理方法
-(void)changeFontsize:(CGFloat)fontsize{
    _contentLabel.font = [UIFont systemFontOfSize:fontsize];
    [self setupContent];
}
@end
