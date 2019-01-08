//
//  HomeCircle.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/20.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.h"
@interface HomeCircle : NSObject

@property (nonatomic,copy) NSString *typeName;

@property (nonatomic,strong) Circle *red;

@property (nonatomic,strong) Circle *green;

@property (nonatomic,strong) Circle *yellow;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,copy) NSString *sumOfNoRead;

@end

