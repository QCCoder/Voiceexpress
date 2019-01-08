//
//  VEAboutUsViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-22.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAboutUsViewController.h"
#import <MessageUI/MessageUI.h>

@interface VEAboutUsViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIImageView *telImageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;

@property (nonatomic, strong) UIWebView *callWebView;

- (IBAction)callAction:(id)sender;
- (IBAction)contactAction:(id)sender;

@end

@implementation VEAboutUsViewController

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
    
    _logoImage.image = Image(Logo_Cyyun);
    _telImageView.image = Image(Icon_Telephone);
    _messageImageView.image = Image(Icon_Message);
    self.title = self.config[About_Us];
    self.callWebView = [[UIWebView alloc] init];
    [self.view addSubview:self.callWebView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction

- (IBAction)callAction:(id)sender
{
    NSURL *telURL = [NSURL URLWithString:@"tel://057428877331"];
    [self.callWebView loadRequest:[NSURLRequest requestWithURL:telURL]];
   
}

- (IBAction)contactAction:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        
        [mailViewController setToRecipients:[NSArray arrayWithObject:kContactApproach]];
        
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
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end












