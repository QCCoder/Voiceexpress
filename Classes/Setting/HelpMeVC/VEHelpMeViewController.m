//
//  VEHelpMeViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEHelpMeViewController.h"
#import "VEHelpMeDetailViewController.h"
#import "VEHelpMeTableViewCell.h"

extern BOOL isTopLeader;
static const NSInteger kBottomImageViewTag = 407;

@interface VEHelpMeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *helpQAData;;


@end

@implementation VEHelpMeViewController

- (void)dealloc
{
    @autoreleasepool {
        self.helpQAData = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"帮助文档";
    NSString *path = nil;
    if (isTopLeader)
    {
        path = [[NSBundle mainBundle] pathForResource:@"helpMe-QAForTopLeader" ofType:@"plist"];
    }
    else
    {
        path = [[NSBundle mainBundle] pathForResource:@"helpMe-QA" ofType:@"plist"];
    }
    self.helpQAData = [NSArray arrayWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.helpQAData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_HelpMe];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_HelpMe owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
  
    UILabel *cellTitleLable = (UILabel *)[cell viewWithTag:kCellTitleTag];
    
    NSDictionary *item = [self.helpQAData objectAtIndex:indexPath.row];
    cellTitleLable.text = [item valueForKey:@"question"];
    cellTitleLable.textColor = unreadFontColor;
    
    if (indexPath.row == (self.helpQAData.count - 1))
    {
        UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"reply_box_line"]];
        bottomImageView.frame = CGRectMake(0.0f,
                                           (cell.contentView.frame.size.height - 1.0f),
                                           (cell.contentView.frame.size.width - 1.0f),
                                           1.0f);
        bottomImageView.contentMode = UIViewContentModeBottom;
        bottomImageView.tag = kBottomImageViewTag;
        [cell.contentView addSubview:bottomImageView];
    }
    else
    {
        for (UIView *subView in [cell.contentView subviews])
        {
            if ([subView isKindOfClass:[UIImageView class]])
            {
                if (subView.tag == kBottomImageViewTag)
                {
                    [subView removeFromSuperview];
                }
            }
        }
    }
    
    [cell.contentView sizeToFit];
    [cell sizeToFit];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = [self.helpQAData objectAtIndex:indexPath.row];
    NSString *question = [item valueForKey:@"question"];
    NSString *answer = [item valueForKey:@"answer"];
    answer = [answer stringByReplacingOccurrencesOfString:@"N" withString:@"\n"];
    
    VEHelpMeDetailViewController *helpMeDetailViewController = [[VEHelpMeDetailViewController alloc] initWithNibName:@"VEHelpMeDetailViewController" bundle:nil];

    helpMeDetailViewController.question = question;
    helpMeDetailViewController.answer = answer;
    
    [self.navigationController pushViewController:helpMeDetailViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
