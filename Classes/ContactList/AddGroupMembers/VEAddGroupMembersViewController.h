//
//  VEAddGroupMembersViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-11-19.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupTool.h"
@interface VEAddGroupMembersViewController : BaseViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) Group *customGroupAgent;

@property (nonatomic,strong) void(^addGroupMember)(Group *customGroupAgent);

@end
