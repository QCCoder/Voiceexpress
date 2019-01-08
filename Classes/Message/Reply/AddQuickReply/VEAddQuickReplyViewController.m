//
//  VEAddQuickReplyViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-12-29.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEAddQuickReplyViewController.h"

@interface VEAddQuickReplyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *promptView;

@property (nonatomic, strong) FYNHttpRequestLoader *httpLoader;

@end

@implementation VEAddQuickReplyViewController

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
    [self.textView becomeFirstResponder];
    self.promptView.layer.cornerRadius = 5.0f;
    [self setupNav];
}

-(void)setupNav{
    [self setTitle:@"新增快捷回复"];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(add:) image:@"ico-ok" highImage:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"AddQuickReply Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
    DLog(@"AddQuickReply Disappear");
}

- (void)cancelAllHttpRequester
{
    [self.httpLoader cancelAsynRequest];
}

#pragma -mark IBAction

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender
{
    NSString *message = self.textView.text;
    NSString *tip = nil;
    if (message.length == 0)
    {
        tip = @"快捷回复内容不能为空";
    }
    else if (message.length > 30)
    {
        tip = @"快捷回复内容限30字内";
    }
    
    if (tip != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:tip
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [self.textView resignFirstResponder];
        [self addQuickMessage:message];
    }
}

#pragma -mark textViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        self.placeholderLabel.hidden = YES;
    }
    else
    {
        self.placeholderLabel.hidden = NO;
    }
}

#pragma -mark My Methods

- (void)showPromptAction
{
    self.promptView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

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

- (void)addQuickMessage:(NSString *)message
{
    if (self.httpLoader == nil)
    {
        self.httpLoader = [[FYNHttpRequestLoader alloc] init];
    }
    
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/QuickReplyAdd", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];

    NSString *params = [NSString stringWithFormat:@"message=%@", [VEUtility encodeToPercentEscapeString:message]];
    
    [self showPromptAction];
    [self.httpLoader cancelAsynRequest];
    [self.httpLoader startAsynRequestWithURL:url withParams:params];
    
    __weak typeof(self) weakSelf = self;
    [self.httpLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        
        [weakSelf stopPromptAction];
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            NSInteger ret = [jsonParser retrieveRusultValue];
            if (ret == 0)
            {
                NSString *quickReplyId = [jsonParser retrieveQuickReplyIdValue];
                [weakSelf updateQuickReplyId:quickReplyId withMessage:message];
            }
            else if (ret == 100)
            {
                NSInteger maxSize = [jsonParser retrieveSizeValue];
                [weakSelf showUptoMaxSize:maxSize];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)updateQuickReplyId:(NSString *)quickReplyId withMessage:(NSString *)quickReplyMessage
{
    QuickReplyAgent *replyAgent = [[QuickReplyAgent alloc] init];
    replyAgent.quickReplyId = quickReplyId;
    replyAgent.quickReplyMessage = quickReplyMessage;
    [self.quickReplyData addObject:replyAgent];
    
    [self goBack];
}

- (void)showUptoMaxSize:(NSInteger)maxSize
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"至多添加%ld条快捷回复", (long)maxSize]
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
