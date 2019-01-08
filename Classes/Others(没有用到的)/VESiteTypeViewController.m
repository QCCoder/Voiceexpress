//
//  VESiteTypeViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VESiteTypeViewController.h"

@interface VESiteTypeViewController ()
{
    NSInteger currentSelectedRow;
}
@property (strong, nonatomic) NSArray *listPrompts;
@end

@implementation VESiteTypeViewController
@synthesize alertRuleDic;
@synthesize listPrompts;

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
    // Do any additional setup after loading the view from its nib.
    self.listPrompts = [[NSArray alloc] initWithObjects:@"全部", @"论坛", @"博客", @"新闻", @"微博", @"纸质媒体", nil];
    currentSelectedRow = [[self.alertRuleDic valueForKey:AlertRuleStyle] integerValue];
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pickerView selectRow:currentSelectedRow inComponent:0 animated:NO];
}


 #pragma mark - UIPickerViewDataSource
 
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
 
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.listPrompts count];
}
 
 #pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.listPrompts objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    currentSelectedRow = row;
}

- (IBAction)back
{
    [self.alertRuleDic setValue:[NSNumber numberWithInteger:currentSelectedRow]
                         forKey:AlertRuleStyle];
    [self.navigationController popViewControllerAnimated:YES];
}

@end





