//
//  VEDeviceLockTimeViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-6-10.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEDeviceLockTimeViewController.h"
#import "VEMainRightDetailTableViewCell.h"

static const NSInteger kVETableViewCellLabelMainTag   = 10;

@interface VEDeviceLockTimeViewController ()

@property (nonatomic, strong) UIView                    *cellSelectedBackgroundView;

- (IBAction)back:(id)sender;

@end

@implementation VEDeviceLockTimeViewController

- (UIView *)cellSelectedBackgroundView
{
    if (_cellSelectedBackgroundView == nil)
    {
        _cellSelectedBackgroundView = [[UIView alloc] init];
        _cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
        [_cellSelectedBackgroundView sizeToFit];
    }
    return _cellSelectedBackgroundView;
}

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
    [self setTitle:@"锁定时间"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_MainRightDetail];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_MainRightDetail owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
        
        cell.selectedBackgroundView = self.cellSelectedBackgroundView;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    UILabel *cellLableMain = (UILabel *)[cell viewWithTag:kVETableViewCellLabelMainTag];
    UIView *itemView = (UIView *)[cell viewWithTag:32];
    for (UIView *view in itemView.subviews) {
        [view removeFromSuperview];
    }
    cellLableMain.text = (indexPath.row == 0 ? @"立即  " : [NSString stringWithFormat:@"%ld分钟", (long)indexPath.row]);
    cellLableMain.textColor = unreadFontColor;
    if ([VEUtility currentPatternLockTime] == indexPath.row){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"login_keep_pressed.pdf"]];
        imageView.ve_size = CGSizeMake(20, 20);
        imageView.ve_x = itemView.ve_width - 20;
        imageView.ve_centerY = itemView.ve_height * 0.5;
        [itemView addSubview:imageView];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = selectedBackgroundColor;
    
    return view;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    [VEUtility setPatternLockTime:indexPath.row];
    
    [tableView reloadData];
}

@end
