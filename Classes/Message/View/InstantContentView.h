//
//  InstantContentView.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNScrollView.h"
#import "IntelligenceAgent.h"
@interface InstantContentView : UIView

@property (nonatomic,weak) SNScrollView *snView;

@property (nonatomic,strong) IntelligenceAgent *agent;

@end
