//
//  VEReplyTableViewCell.h
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyAgent.h"
static NSString * const KIdentifier_ReplyComment   = @"CellReplyComment";
static NSString * const KIdentifier_ReplyTip       = @"CellReplyTip";
static NSString * const KIdentifier_NoReplyMeReply = @"CellNoReplyAndMeReply";
static NSString * const KIdentifier_NoReply        = @"CellNoReply";

static NSString * const KNibName_Reply    = @"VEReplyTableViewCell";


static const NSInteger kMeReplyBtnTag                 = 301;


typedef enum{
    VEReplyTableViewCellReplyTipIndex,
    VEReplyTableViewCellNoReplyMeReplyIndex,
    VEReplyTableViewCellNoReplyIndex,
}ReplyIndex;

//static const NSInteger VEReplyTableViewCellReplyCommentIndex   = 0;
//static const NSInteger VEReplyTableViewCellReplyTipIndex       = 1;
//static const NSInteger VEReplyTableViewCellNoReplyMeReplyIndex = 2;
//static const NSInteger VEReplyTableViewCellNoReplyIndex        = 3;

@interface VEReplyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelSender;
@property (strong, nonatomic) IBOutlet UILabel *labelTip;
@property (strong, nonatomic) IBOutlet UITextView *textViewReplyContent;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *replyBtn;


@property (nonatomic,assign) BOOL addBottomLine;
@property (nonatomic,strong) ReplyAgent *agent;

+(instancetype)cellWithTableView:(UITableView *)tableView index:(ReplyIndex)index identifier:(NSString *)identifier;

+(instancetype)cellWithTableview:(UITableView *)tableView;

@end
