//
//  VETableViewCell.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-17.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
static const NSInteger VETableViewCellContactIndex                  = 0;
static const NSInteger VETableViewCellCustomGroupIndex              = 1;
static const NSInteger VETableViewCellCellSecondContactIndex        = 2;
static const NSInteger VETableViewCellThirdContactIndex             = 3;

#define kCellName @"VETableViewCell"

@interface VETableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thirdBtn;

@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitleLabel;

@property (nonatomic,strong) GroupMember *groupMember;
@property (nonatomic,strong) Group *group;
@property (nonatomic,assign) NSIndexPath *indexPath;

@property (nonatomic,copy) void(^doFavorite)(GroupMember *groupMember,NSIndexPath *indexPath,UIActivityIndicatorView *indicator);
@property (nonatomic,copy) void(^deleteGroupItem)();
@property (nonatomic,copy) void(^showAll)(UIButton *btn);

+(instancetype)cellWithTableView:(UITableView *)tableView index:(NSInteger)index indentifier:(NSString *)indentifier;



@end
