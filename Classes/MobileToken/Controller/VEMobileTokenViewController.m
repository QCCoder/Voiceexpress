//
//  VEMobileTokenViewController.m
//  voiceexpress
//
//  Created by 钱城 on 15/11/3.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VEMobileTokenViewController.h"
#import "UIView+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "VETokenView.h"
#import "TOTPGenerator.h"
#import "MF_Base32Additions.h"
#import "VETokenTool.h"
#define kTime 30


@interface VEMobileTokenViewController ()

@property (nonatomic,copy) NSString *secretData;
@property (nonatomic,weak) VETokenView *tokenView;
@property (nonatomic,weak) UILabel *serviceTime;
@end

@implementation VEMobileTokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _secretData = @"";
    //设置导航栏
    [self setupNav];
    
    //内容
    [self setupContent];
    
    //30秒获取一个令牌
    NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showNewNumber) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showNewNumber];
}
/**
 * 设置导航栏
 */
-(void)setupNav{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:self.config[MainColor]]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title= self.config[MobileToken];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(showMenu) image:self.config[Tab_Ico_List] highImage:nil];
}

-(void)setupContent
{
    VETokenView *contentView = [[VETokenView alloc]init];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    CGFloat W= 266;
    CGFloat X =([UIScreen mainScreen].bounds.size.width - W)/2;
    contentView.frame = CGRectMake(X, 50, W, 150);
    [self.view addSubview:contentView];
    _tokenView = contentView;
    contentView.second = 15;
    
    UILabel *serviceTime = [[UILabel alloc]init];
    [serviceTime setFont:[UIFont systemFontOfSize:13.0]];
    [serviceTime setTextColor:RGBCOLOR(136, 136, 136)];
    [serviceTime setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, self.view.frame.size.height - 90, 60, 25)];
    [self.view addSubview:serviceTime];
    _serviceTime = serviceTime;
    serviceTime.hidden = YES;
}

-(void)showNewNumber
{
    NSDictionary *time = [VETokenTool getServiceTime];
    long timestamp = [time[@"timestamp"] integerValue];
    NSString *dateString = time[@"date"];
    if(timestamp % kTime != 0){
        timestamp -= timestamp % kTime;
    }
    [_serviceTime setText:[dateString substringFromIndex:10]];
    NSInteger second = [[dateString substringFromIndex:17] integerValue] % 30;
    [self generatePIN:second timestamp:timestamp];
    
}

-(void)generatePIN:(NSInteger )second timestamp:(NSInteger )timestamp
{
    _secretData = [DES3Util decrypt:[VEUtility currentMobileToken]];
    
    NSData *secretData =  [NSData dataWithBase32String:_secretData];
    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:kDigits period:kTime];
    NSString *pin = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    _tokenView.second = second;
    _tokenView.token = pin;
}
-(void)showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

@end
