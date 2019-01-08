//
//  HttpImage.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/16.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HttpImage : UIView

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,strong) NSData *data;

@end
