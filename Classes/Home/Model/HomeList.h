//
//  HomeList.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/13.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeList : NSObject

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *icon;

@property (nonatomic,assign) BOOL hasNew;

@property (nonatomic,copy) NSString *newsTitle;

@end
