//
//  VEPopViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-14.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEPopViewController.h"

@interface VEPopViewController ()
@property (strong, nonatomic) NSArray *listData;
@property (assign, nonatomic) NSInteger currentSelectedRow;
@end

@implementation VEPopViewController
@synthesize listData;
@synthesize whichParent;
@synthesize delegate;
@synthesize currentSelectedRow;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    if (self.whichParent == FromSearchAlert)
    {
        self.contentSizeForViewInPopover = CGSizeMake(100.0, 120.0);
         self.listData = [[NSArray alloc] initWithObjects:@"搜标题", @"搜内容", @"搜全部", nil];
    }
    else
    {
        self.contentSizeForViewInPopover = CGSizeMake(130.0, 160.0);
        self.listData = [[NSArray alloc] initWithObjects:@"刷新全部数据",@"内容筛选", @"全部标记已读", @"预警规则设置", nil];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.text = [self.listData objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f];
    
    UIView *cellSelectedBackgroundView = [[UIView alloc] init];
    cellSelectedBackgroundView.backgroundColor = BarTintColor;//[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0f];;
    [cellSelectedBackgroundView sizeToFit];

    cell.selectedBackgroundView = cellSelectedBackgroundView;
   
    
    if ((self.whichParent == FromSearchAlert) &&
        (indexPath.row == self.currentSelectedRow))
    {
        [tableView selectRowAtIndexPath:indexPath
                               animated:YES
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate popViewDidSelectRowAtIndex:indexPath.row];
    self.currentSelectedRow = indexPath.row;
    
  if (self.whichParent != FromSearchAlert)
  {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

@end
