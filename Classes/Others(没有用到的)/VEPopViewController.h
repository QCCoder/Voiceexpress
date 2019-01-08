//
//  VEPopViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-14.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopViewProtocol
- (void) popViewDidSelectRowAtIndex:(NSInteger)row;
@end

@interface VEPopViewController : UITableViewController
@property (assign, nonatomic) NSInteger whichParent;
@property (unsafe_unretained, nonatomic) id<PopViewProtocol> delegate;
@end
