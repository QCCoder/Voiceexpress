//
//  ZLNavigationController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15/11/25.
//  Copyright © 2015年 com.zixue101.www. All rights reserved.
//

#import "ZLNavigationController.h"

@interface ZLNavigationController ()

@end

@implementation ZLNavigationController

+(void)initialize
{
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarTintColor:[UIColor colorWithHexString:Config(MainColor)]];
    [bar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    
    //设置普通状态的文字属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if (self.viewControllers.count > 0) {
//        viewController.hidesBottomBarWhenPushed = YES;
//        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(goBack) image:@"ico-back" highImage:@"ico-back"];
//    }
//    
//    [super pushViewController:viewController animated:YES];
//}

//-(void)goBack
//{
//    [self popViewControllerAnimated:YES];
//}

@end
