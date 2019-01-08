//
//  VENavViewController.m
//  voiceexpress
//
//  Created by apple on 15/11/9.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VENavViewController.h"

@interface VENavViewController ()

@property (weak,nonatomic) UIViewController *rootVC;

@end

@implementation VENavViewController

+(void)initialize
{
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarTintColor:[UIColor colorWithHexString:Config(MainColor)]];
    [bar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)setIconType:(BOOL)iconType
{
    _iconType = iconType;
    if (_iconType) {
        _rootVC.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goMenu) image:Config(Tab_Ico_List_Red) highImage:@""];
    }else{
        _rootVC.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goMenu) image:Config(Tab_Ico_List) highImage:@""];
    }

}

-(void)reloadImage{
    
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarTintColor:[UIColor colorWithHexString:Config(MainColor)]];
    
    [bar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    if (_iconType) {
        _rootVC.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goMenu) image:Config(Tab_Ico_List_Red) highImage:@""];
    }else{
        _rootVC.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goMenu) image:Config(Tab_Ico_List) highImage:@""];
    }
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    _rootVC = rootViewController;
    rootViewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goMenu) image:Config(Tab_Ico_List) highImage:nil];
    return [super initWithRootViewController:rootViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadImage) name:RELOADIMAGE object:nil];
    self.navigationBar.translucent = NO;
    // 右滑手势返回
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goBack) image:Config(Tab_Icon_Back) highImage:nil];
    }
    [super pushViewController:viewController animated:YES];
}

-(void)goBack
{
    [self popViewControllerAnimated:YES];
}

-(void)goMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(BOOL)prefersStatusBarHidden
{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOADIMAGE object:nil];
}

@end
