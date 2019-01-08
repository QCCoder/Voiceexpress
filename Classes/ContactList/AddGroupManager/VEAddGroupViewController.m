//
//  VEAddGroupViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEAddGroupViewController.h"
#import "VEAddGroupMembersViewController.h"
#import "GroupTool.h"

@interface VEAddGroupViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField               *textField;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (nonatomic, strong) Group *customGroupAgent;

@end

@implementation VEAddGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.promptView.layer.cornerRadius = 5.0;
    
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    [self setupNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"AddGroupList Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"AddGroupList Disappear");
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [super viewDidUnload];
}

-(void)setupNav{
    [self setTitle:self.config[AddGroup]];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(createGroup) image:self.config[Ico_Next] highImage:nil];
    self.navigationItem.leftBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(goback) image:self.config[Tab_Icon_Back] highImage:nil];
}

- (void)createGroup
{
    if (self.customGroupAgent != nil && self.customGroupAgent.groupName.length > 0)
    {
        [self addGroupMembers];
    }
    else
    {
        NSString *groupName = self.textField.text;
        NSInteger length = groupName.length;
        if (length >= 2 && length <= 10)
        {
            [self.textField resignFirstResponder];
            [self addCustomGroupName:groupName];
        }
        else
        {
            NSString *message = (length < 2 ? @"分组名至少2个字" : @"分组名至多10个字");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"好的"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

-(void)goback{
    if (self.addGroupList) {
        self.addGroupList(self.customGroupList);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - My Methods

- (void)startShowPromptViewWithTip:(NSString *)tip
{
    self.promptView.alpha = 0;
    self.labelTip.text = tip;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPromptView
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.lableTip.text = nil;
                     }
     ];
}

- (void)addGroupMembers
{
    VEAddGroupMembersViewController *addMembersVC = [[VEAddGroupMembersViewController alloc] initWithNibName:@"VEAddGroupMembersViewController" bundle:nil];
    addMembersVC.customGroupAgent = self.customGroupAgent;
    addMembersVC.addGroupMember = ^(Group *customGroupAgent){
        self.customGroupAgent = customGroupAgent;
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:addMembersVC animated:YES];
}

- (void)addCustomGroupName:(NSString *)groupName
{
    [GroupTool addCustomGroupWithName:groupName resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [self successToAddCustomGroup:JSON];
        }else{
            if (JSON) {
                [self failedToAddCustomGroupOnMaxSize:[JSON integerValue]];
            }
        }
    }];
}

- (void)successToAddCustomGroup:(Group *)group
{
    self.customGroupAgent = group;
    [self.customGroupList addObject:self.customGroupAgent];
    // 添加组成员
    [self addGroupMembers];
}

- (void)failedToAddCustomGroupOnMaxSize:(NSInteger)maxSize
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"至多添加%ld个分组", (long)maxSize]
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
