//
//  VELatestAlertFilterViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-20.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VELatestAlertFilterViewController.h"
#import "VELatestAlertFilterResultsViewController.h"
#import "VEFilterLevelTableViewCell.h"
#import "VELatestAlertViewController.h"

static NSString * const kUrgentFilterLevel  = @"VEFilterLevelUrgent";
static NSString * const kSeriousFilterLevel = @"VEFilterLevelSerious";
static NSString * const kGeneralFilterLevel = @"VEFilterLevelGeneral";

@interface VELatestAlertFilterViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UISwitch *urgentLevelSwitcher;
@property (strong, nonatomic) UISwitch *seriousLevelSwitcher;
@property (strong, nonatomic) UISwitch *generalLevelSwitcher;

@end

@implementation VELatestAlertFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"LatestAlertFilter Disappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"LatestAlertFilter Disappear");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VEWarnAlertTableViewCell" bundle:nil] forCellReuseIdentifier:@"VEWarnAlertTableViewCell"];
    
    self.urgentLevelSwitcher = [[UISwitch alloc] init];
    self.seriousLevelSwitcher = [[UISwitch alloc] init];
    self.generalLevelSwitcher = [[UISwitch alloc] init];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    self.urgentLevelSwitcher.on  = ![defaults boolForKey:kUrgentFilterLevel];
    self.seriousLevelSwitcher.on = ![defaults boolForKey:kSeriousFilterLevel];
    self.generalLevelSwitcher.on = ![defaults boolForKey:kGeneralFilterLevel];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = self.config[FitterContent];
    UIBarButtonItem *send =[UIBarButtonItem itemWithTarget:self action:@selector(doFilterAction) image:Config(Tab_Icon_Ok) highImage:nil];
    self.navigationItem.rightBarButtonItem = send;
    
}



#pragma mark - IBAction

- (void)doFilterAction
{
    NSString *filterWarnLevel = @"";
    if (self.urgentLevelSwitcher.on)     // 紧急预警
    {
        filterWarnLevel = [filterWarnLevel stringByAppendingString:@"1_"];
    }
    if (self.seriousLevelSwitcher.on)    // 重要预警
    {
        filterWarnLevel = [filterWarnLevel stringByAppendingString:@"2_"];
    }
    if (self.generalLevelSwitcher.on)     // 一般预警
    {
        filterWarnLevel = [filterWarnLevel stringByAppendingString:@"3_"];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [defaults setBool:!self.urgentLevelSwitcher.on forKey:kUrgentFilterLevel];
    [defaults setBool:!self.seriousLevelSwitcher.on forKey:kSeriousFilterLevel];
    [defaults setBool:!self.generalLevelSwitcher.on forKey:kGeneralFilterLevel];
    [defaults synchronize];
    
    if ([filterWarnLevel length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"请选择要筛选的预警等级"
                                                          delegate:nil
                                                 cancelButtonTitle:@"好的"
                                                 otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        VELatestAlertFilterResultsViewController *alertFilterResultsViewController = [[VELatestAlertFilterResultsViewController alloc] initWithNibName:@"VELatestAlertFilterResultsViewController" bundle:nil];
        alertFilterResultsViewController.filterWarnLevel = filterWarnLevel;
        
        [self.navigationController pushViewController:alertFilterResultsViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_FilterLevel];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_FilterLevel owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    VEFilterLevelTableViewCell *filterCell = (VEFilterLevelTableViewCell *)cell;
    filterCell.labelMain.textColor = unreadFontColor;

    UISwitch *switcher = nil;
    UIImage *image     = nil;
    NSString *title    = nil;
    
    if (indexPath.row == 0)
    {
        switcher = self.urgentLevelSwitcher;
        image    = Image(Icon_Circle_Red);
        title    = self.config[Urgent];
    }
    else if (indexPath.row == 1)
    {
        switcher = self.seriousLevelSwitcher;
        image    = Image(Icon_Circle_Yellow);
        title    = self.config[Import];
    }
    else
    {
        switcher = self.generalLevelSwitcher;
        image    = Image(Icon_Circle_Blue);
        title    = self.config[Normal];
    }
    
    filterCell.imageLevel.image = image;
    filterCell.labelMain.text = title;
//    cell.accessoryView = switcher;
    UIView *itemView = (UIView *)[cell viewWithTag:32];
    [itemView addSubview:switcher];
    [switcher sizeToFit];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable = [[UILabel alloc] init];
    if (section == 0)
    {
        lable.textColor = unreadFontColor;
        lable.backgroundColor = selectedBackgroundColor;
        lable.font = [UIFont boldSystemFontOfSize:15];
        lable.text = self.config[WarnLevelTip];
    }
    
    return lable;
}

@end
