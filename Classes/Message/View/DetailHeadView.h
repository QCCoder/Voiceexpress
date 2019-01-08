//
//  DetailHeadView.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetilHead.h"
@interface DetailHeadView : UIView

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) DetilHead *data;

-(void)showReceiver;

@property (nonatomic,copy) void(^showList)(CGFloat height);

@end
