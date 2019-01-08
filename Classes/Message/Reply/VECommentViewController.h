//
//  VECommentViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-3-4.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VECommentViewController : UIViewController

@property (nonatomic, copy) NSString *articleID;
@property (nonatomic, copy) NSString *receiverID;
@property (nonatomic, copy) NSString *receiverName;

@property (nonatomic,copy) void(^replySuccess)();


@end
