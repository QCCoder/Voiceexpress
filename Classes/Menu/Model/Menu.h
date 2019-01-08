//
//  Menu.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *icon;

@property (nonatomic,assign) BOOL hasNew;

@property (nonatomic,assign) BOOL isSelected;
@end
