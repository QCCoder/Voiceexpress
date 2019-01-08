//
//  VENewAlertRuleDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VENewAlertRuleDetailViewController.h"

extern BOOL VENewAlertRuleViewIsAlertRuleChanged;

@interface VENewAlertRuleDetailViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *promptLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) NSArray *keyArray;
- (IBAction)backgroundTapped;
- (IBAction)back;
- (IBAction)saveContent;
@end

@implementation VENewAlertRuleDetailViewController

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
    [VEUtility initBackgroudImageOfToolBar:self.toolBar];
    
    self.labelTitle.text = self.titleName;
    self.keyArray = [[NSArray alloc] initWithObjects:AlertRuleName, AlertRuleAndKeywords, AlertRuleNonKeywords, AlertRuleReplyCount, AlertRuleReadCount, AlertRuleStyle, nil];
}

- (void)viewDidUnload
{
    [self setPromptLabel:nil];
    [self setTextView:nil];
    [self setLabelTitle:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.titleName;
    if (self.fromRow == 0)
    {
        self.promptLabel.text = @"请输入预警规则名称，必填项。";
    }
    else if (self.fromRow == 1 || self.fromRow == 2)
    {
        self.promptLabel.text = @"多个关键词之间请用 “分号” 隔开。";
    }
    else if (self.fromRow == 3 || self.fromRow == 4)
    {
        self.promptLabel.text = @"请输入整数，默认0为不限。";
        self.textView.keyboardType = UIKeyboardTypeNumberPad;
    }
    else
    {
        self.promptLabel.text = nil;
    }
    
    NSString *key = [self.keyArray objectAtIndex:self.fromRow];
    if (key != nil) self.textView.text = [self.alertRuleDic objectForKey:key];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTapped
{
    [self.textView resignFirstResponder];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

 #define MAXINTVALUE      2147483647
- (IBAction)saveContent
{
    NSString *content = self.textView.text;
    NSString *key = [self.keyArray objectAtIndex:self.fromRow];
    if (key != nil)
    {
        if (self.fromRow == 3 || self.fromRow == 4)
        {
            long long counts = [content longLongValue];
            if (counts > MAXINTVALUE)
            {
                NSString *message = @"阅读转发数过大";
                if (self.fromRow == 3 )
                {
                    message = @"回复数过大";
                }
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"好的"
                                                     otherButtonTitles:nil];
                [alert show];
                return;
            }
            else
            {
                content = [[NSNumber numberWithInteger:[content integerValue]] stringValue];
            }
        }
        else
        {
            content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];  // 去除换行符
            content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];   // 去除空格
        }
        if ([content isEqualToString:[self.alertRuleDic valueForKey:key]] == NO)
        {
            VENewAlertRuleViewIsAlertRuleChanged = YES;
        }
        
        [self.alertRuleDic setValue:content forKey:key];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
