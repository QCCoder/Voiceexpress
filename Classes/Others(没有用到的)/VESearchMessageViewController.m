//
//  VESearchMessageViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-4-28.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VESearchMessageViewController.h"

@interface VESearchMessageViewController ()

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;
- (IBAction)back:(id)sender;

@end

@implementation VESearchMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [VEUtility initBackgroudImageOfToolBar:self.toolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setToolBar:nil];
    [super viewDidUnload];
}
@end
