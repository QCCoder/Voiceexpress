//
//  VEHelpMeDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEHelpMeDetailViewController.h"

@interface VEHelpMeDetailViewController ()

@property (strong, nonatomic) IBOutlet UILabel              *questionLabel;
@property (strong, nonatomic) IBOutlet UITextView           *answerTextView;

- (IBAction)back;

@end

@implementation VEHelpMeDetailViewController

@synthesize question, answer;

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
    [self setTitle:@"正文"];
    self.questionLabel.text = self.question;
    self.answerTextView.text = self.answer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setQuestionLabel:nil];
    [self setAnswerTextView:nil];
    
    self.answer = nil;
    self.question = nil;
    
    [super viewDidUnload];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
