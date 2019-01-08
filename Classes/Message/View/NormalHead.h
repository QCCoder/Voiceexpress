//
//  NormalHead.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntelligenceAgent.h"
@interface NormalHead : UIView

@property (nonatomic,strong) IntelligenceAgent *agent;

@property (nonatomic,copy) NSString *columnName;

@end
