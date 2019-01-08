//
//  VECommentViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-3-4.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VECommentViewController.h"
#import "VEQuickReplyViewController.h"

BOOL bReplySuccess = NO;

@interface VECommentViewController ()
@property (weak, nonatomic) UIButton *replyBtn;

@property (weak, nonatomic) IBOutlet UITextView                *commentTextView;
@property (weak, nonatomic) UILabel                   *labelReceiverName;
@property (weak, nonatomic) UILabel                   *labelReceiverTip;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;

@property (strong, nonatomic) FYNHttpRequestLoader *httpReplyContentUploader;
@property (strong, nonatomic) NSMutableArray *selQuickReplys;

- (IBAction)back:(UIBarButtonItem *)sender;
- (IBAction)doComment:(UIBarButtonItem *)sender;
- (IBAction)quickReply:(id)sender;


@property (nonatomic,strong) UIView *bottomView;
@end

@implementation VECommentViewController


-(UIView *)bottomView
{
    if (!_bottomView) {
        UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, Main_Screen_Height - 108, Main_Screen_Width, 44)];
        [bottomView setBackgroundColor:RGBCOLOR(224, 225, 224)];
        [self.view addSubview:bottomView];
        self.bottomView = bottomView;
        
        UILabel *labelReceiverTip = [[UILabel alloc]initWithFrame:CGRectMake(10, 11, 42, 21)];
        [labelReceiverTip setText:@"回复"];
        [labelReceiverTip setFont:[UIFont boldSystemFontOfSize:16.0]];
        [labelReceiverTip setTextColor:RGBCOLOR(68, 68, 68)];
        [bottomView addSubview:labelReceiverTip];
        _labelReceiverTip = labelReceiverTip;
        
        
        UILabel *labelReceiverName= [[UILabel alloc]initWithFrame:CGRectMake(55, 11, 152, 21)];
        [labelReceiverName setText:@"回复"];
        [labelReceiverName setFont:[UIFont boldSystemFontOfSize:16.0]];
        [labelReceiverName setTextColor:RGBCOLOR(5, 169, 248)];
        [bottomView addSubview:labelReceiverName];
        _labelReceiverName = labelReceiverName;
        
        UIButton *replyBtn = [[UIButton alloc]initWithFrame:CGRectMake(Main_Screen_Width - 70 , 11, 60, 22)];
        [replyBtn setBackgroundImage:[UIImage imageNamed:@"reply_normal.png"] forState:UIControlStateNormal];
        [replyBtn setTitleColor:RGBCOLOR(245, 245, 245) forState:UIControlStateNormal];
        [replyBtn setTitle:@"快捷回复" forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(quickReply:) forControlEvents:UIControlEventTouchUpInside];
        [replyBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [bottomView addSubview:replyBtn];
    }
    return _bottomView;
}

- (FYNHttpRequestLoader *)httpReplyContentUploader
{
    if (_httpReplyContentUploader == nil)
    {
        _httpReplyContentUploader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpReplyContentUploader;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bottomView.hidden = NO;
    
    [self initLayout];
    self.labelReceiverName.text = self.receiverName;
    self.promptView.layer.cornerRadius = 5.0;
    [self setupNav];
}

-(void)setupNav{
    [self setTitle:@"回复"];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(doComment:) image:Config(Tab_Icon_Ok) highImage:@""];
}
- (void)viewDidUnload
{
    [self setBottomView:nil];
    [self setCommentTextView:nil];
    [self setLabelReceiverName:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [self setLabelReceiverTip:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"Reply Appear");
    if (self.selQuickReplys.count > 0)
    {
        self.commentTextView.text = [self.selQuickReplys lastObject];
        [self.selQuickReplys removeAllObjects];
    }
    self.bottomView.hidden = NO;
    [self.commentTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     DLog(@"Reply Disappear");
    self.bottomView.hidden = YES;
    [self.commentTextView resignFirstResponder];
    [self cancelAllHttpRequester];
}

- (void)cancelAllHttpRequester
{
    if (_httpReplyContentUploader)
    {
        [self.httpReplyContentUploader cancelAsynRequest];
    }
}

- (void)initLayout
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration = (animationDuration > 0 ? animationDuration : 0.25);
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.ve_y = [value CGRectValue].origin.y - self.bottomView.ve_height - 63;
    }];
}

- (IBAction)back:(UIBarButtonItem *)sender
{

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doComment:(UIBarButtonItem *)sender
{
    NSString *replyContent = self.commentTextView.text;
    
    if ([replyContent length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"回复内容不能为空"
                                                          delegate:nil
                                                 cancelButtonTitle:@"好的"
                                                 otherButtonTitles:nil];
        [alertView show];
        return;
    }

    NSString *stringUrl = [NSString stringWithFormat:@"%@/CustomWarnReplyAdd", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
   
    // 3DES加密、UTF8编码
    NSString *encode3DESReplyContent = [DES3Util encrypt:replyContent];
    NSString *encodeReplyContent = [VEUtility encodeToPercentEscapeString:encode3DESReplyContent];

    NSString *paramsStr = [NSString stringWithFormat:@"cwid=%@&repliedUser=%@&isPrivate=1&replyContent=%@",
                           self.articleID, self.receiverID, encodeReplyContent];
  
    [self showPromptAction];
    
    [self.httpReplyContentUploader cancelAsynRequest];
    [self.httpReplyContentUploader startAsynRequestWithURL:url withParams:paramsStr];
    
    __weak typeof(self) weakSelf = self;
    [self.httpReplyContentUploader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        [weakSelf stopPromptAction];
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateCommentAction];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (IBAction)quickReply:(id)sender
{
    if (self.selQuickReplys == nil)
    {
        self.selQuickReplys = [NSMutableArray array];
    }
    
    VEQuickReplyViewController *quickReplyVC = [[VEQuickReplyViewController alloc] initWithNibName:@"VEQuickReplyViewController" bundle:nil];
    quickReplyVC.selQuickReplys = self.selQuickReplys;
    
    [self.navigationController pushViewController:quickReplyVC animated:YES];
}

- (void)updateCommentAction
{
    bReplySuccess = YES;
    if (self.replySuccess) {
        self.replySuccess();
    }
    [self back:nil];
}

#pragma mark - My Methods

- (void)showPromptAction
{
    self.promptView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

// 停止显示加载数据的提示框
- (void)stopPromptAction
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                     }
     ];
}

@end
