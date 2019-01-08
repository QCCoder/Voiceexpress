//
//  VEOriginalViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEOriginalViewController.h"

@interface VEOriginalViewController () <NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIWebView                 *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;

- (IBAction)back:(id)sender;
- (IBAction)reloadPage:(id)sender;

@end

@implementation VEOriginalViewController

- (void)dealloc
{
    [self.webView stopLoading];
    self.webView.delegate = nil; 
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    self.promptView.layer.cornerRadius = 5.0;
    [self reloadPage:nil];
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = @"原文";
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(reloadPage:) image:self.config[Tab_Icon_Refresh] highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;  
}

- (void)viewDidUnload
{
    self.originalUrl = nil;
    [self setWebView:nil];
    [self setIndicator:nil];
    [self setPromptView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reloadPage:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.originalUrl]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    [self.webView stopLoading];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showPromptAction];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopPromptAction];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"open url: (%@) error: %@", self.originalUrl, [error localizedDescription]);
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
    [self.webView stopLoading];
    [self stopPromptAction];
}

#pragma mark - MyMethods

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

@end
