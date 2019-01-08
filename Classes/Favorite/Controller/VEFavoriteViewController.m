//
//  VEFavoriteViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEFavoriteViewController.h"
#import "VEFavoriteTableViewCell.h"
#import "VEFavoriteDetailViewController.h"

@interface VEFavoriteViewController ()

@property (weak, nonatomic) IBOutlet UITableView   *tableView;

@end

@implementation VEFavoriteViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"FavoriteView Disappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"FavoriteView Disappear");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refleshToggleButtonOnRed];
    [self setTitle:self.config[Favourites]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VEFavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"VEFavoriteTableViewCell"];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];    
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}


- (void)loadNumberForLabel:(UILabel *)cellCountLabel AtIndex:(NSInteger)index
{
    NSDictionary *paramters;
    if (index == FavoriteDetailViewFavoriteFromAlerts){
        paramters = @{@"warnType":@"1"};
    }else if (index == FavoriteDetailViewFavoriteFromRecommend){
        paramters = @{@"warnType":@"3"};
    }
    
    [HttpTool getWithUrl:@"WarnFavoritesCounts" Parameters:paramters Success:^(id JSON) {
        NSInteger result = [JSON[@"result"] integerValue];
        if (result == 0) {
            cellCountLabel.text = [NSString stringWithFormat:@"%@条",JSON[@"count"]];
        }else{
            cellCountLabel.text = @"加载失败";
        }
    } Failure:^(NSError *error) {
        DLog(@"%@",[error localizedDescription]);
        cellCountLabel.text = @"加载失败";
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VEFavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VEFavoriteTableViewCell"];
    if (cell == nil)
    {
        cell= (VEFavoriteTableViewCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"VEFavoriteTableViewCell" owner:self options:nil]  lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger section = indexPath.section;

    if (section == FavoriteDetailViewFavoriteFromAlerts){
        cell.cellTitleLabel.text  = self.config[WarnAlertTitle];
        cell.logImageView.image   = Image(Icon_Favorite_Alerts);
        cell.levellImageView.image = Image(Icon_List_Red);
    }else if (section == FavoriteDetailViewFavoriteFromRecommend){
        cell.cellTitleLabel.text = self.config[ReadTitle];
        cell.logImageView.image = Image(Icon_Favorite_Recommend);
        cell.levellImageView.image = Image(Icon_List_Green);
    }
    cell.countsLabel.textColor = readFontColor;
    [self loadNumberForLabel:cell.countsLabel AtIndex:section];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VEFavoriteDetailViewController *favoriteDetailViewCOntroller = [[VEFavoriteDetailViewController alloc] initWithNibName:@"VEFavoriteDetailViewController" bundle:nil];
    favoriteDetailViewCOntroller.comeFrom = indexPath.section;
    
    [self.navigationController pushViewController:favoriteDetailViewCOntroller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

#pragma mark - Notification

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

- (void)dealloc
{
    @autoreleasepool {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}
@end
