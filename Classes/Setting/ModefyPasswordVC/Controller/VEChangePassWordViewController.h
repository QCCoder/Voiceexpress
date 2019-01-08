//
//  VEChangePassWordViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-22.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Operation)
{
    OperationChangeDefaultPassword = 601,
};

@interface VEChangePassWordViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) Operation action;

@end
