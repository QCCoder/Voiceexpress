
//  VERecommendReadDetailVC.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/12.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VERecommendReadDetailVC.h"
#import <MessageUI/MessageUI.h>
#import "NSAttributedString+Height.h"
#import "ArticledetailTool.h"
#import "RecommendReadTool.h"
#import "UIImageView+SD.h"
#import "DetailLabel.h"
#import "VEMessageDistributeViewController.h"
#import "PhotoBroswerVC2.h"

@interface VERecommendReadDetailVC ()<ArticleDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (nonatomic,weak) DetailLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@end

@implementation VERecommendReadDetailVC

-(DetailLabel *)contentLabel
{
    if (!_contentLabel) {
        DetailLabel *name = [[DetailLabel alloc]initWithFrame:CGRectMake(_titleLabel.ve_x, 0, 0, 0)];
        name.numberOfLines = 0;
        [self.scrollView addSubview:name];
        self.contentLabel = name;
    }
    return _contentLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadImage];
    
    [self setupContent];
    
    [self loadContent];
    
    [self loadWarnFavoritesState];
    
    [self.showMoreBtn setImage:Image(Tab_Icon_More) forState:UIControlStateNormal];
}

-(void)viewDidLayoutSubviews{
    [self setupContent];
}

-(void)reloadImage{
    self.title = self.config[Body];
    _agent.articleContent = @"正在加载内容,请稍等...";
    [_favoriteBtn setImage:Image(Icon_Favourite) forState:UIControlStateNormal];
    [_favoriteBtn setImage:Image(Icon_Nofavourite) forState:UIControlStateSelected];
    _footView.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
}

#pragma mark 我的方法

/**
 *  初始化设置
 */
-(void)setupContent{
    _scrollView.alwaysBounceVertical = YES;
    
    _titleLabel.text = _agent.title;
    _titleLabel.ve_width = Main_Screen_Width - 32;
    
    CGFloat titleY = [_titleLabel.text boundingRectWithSize:CGSizeMake( _timeLabel.ve_width,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.height;
    _titleLabel.ve_height = titleY;
    
    _timeLabel.text = _agent.timePost;
    CGFloat Y = 0;
    if (_agent.thumbImageUrl.length) {
        Y = CGRectGetMaxY(_imageCountLabel.frame) + 5;
        [_imageView imageWithUrlStr:_agent.thumbImageUrl phImage:Image(Icon_Picture_Min)];
        _imageCountLabel.text = [NSString stringWithFormat:@"点击查看（共%ld张）",(unsigned long)_agent.imageUrls.count];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [_imageView addGestureRecognizer:tapGestureRecognizer];
        
    }else{
        Y = CGRectGetMaxY(_timeLabel.frame) + 10;
        _imageView.hidden = YES;
        _imageCountLabel.hidden = YES;
    }
    self.contentLabel.ve_y = Y;
    self.contentLabel.text = _agent.articleContent;

    CGFloat maxContentY = CGRectGetMaxY(self.contentLabel.frame) + 7;
    CGFloat maxScrollViewY = CGRectGetMaxY(self.scrollView.frame);
    CGFloat maxY = maxScrollViewY;
    if (maxContentY > maxScrollViewY ) {
        maxY = maxContentY;
    }
    
    _scrollView.contentSize = CGSizeMake(0, maxY);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"RecommendDetail Disappear");
    [self setupContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"RecommendDetail Disappear");
}


/**
 *  加载文章详情
 */
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

#pragma mark 事件监听
/**
 *  查看图片
 *
 */
-(void)clickImage{
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC2 show:self type:PhotoBroswerVCTypeZoom index:0 photoModelBlock:^NSArray *{
        NSMutableArray *modelM = [NSMutableArray arrayWithCapacity:weakSelf.agent.imageUrls.count];
        for (NSUInteger i = 0; i < weakSelf.agent.imageUrls.count; i++) {
            PhotoModel *phModel = [[PhotoModel alloc]init];
            phModel.mid = i+1;
            phModel.image_HD_U = weakSelf.agent.imageUrls[i][@"imageUrl"];
            phModel.sourceImageView = weakSelf.imageView;
            [modelM addObject:phModel];
        }
        return modelM;
    }];
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
    distributeViewController.sendType               = SendTypeForwardFromRecommendRead;
    distributeViewController.agent = detailAgent;
    distributeViewController.imageUrls = self.agent.imageUrls;
    [self.navigationController pushViewController:distributeViewController animated:YES];
}

- (IBAction)showList:(id)sender {
    ArticledetailTool *detailTool = [[ArticledetailTool alloc]init];
    detailTool.delegate = self;
    [detailTool showList:self agent:_agent];
}


#pragma mark 代理方法
-(void)changeFontsize:(CGFloat)fontsize{
    _contentLabel.font = [UIFont systemFontOfSize:fontsize];
    [self setupContent];
}
@end
