//
//  VENetWorkReportingTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VENetWorkReportingTableViewCell.h"

@interface VENetWorkReportingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bkView;

@property (nonatomic,strong) UIImage *selectedImage;
@end

@implementation VENetWorkReportingTableViewCell

+ (UIView *)cellSelectedBackgroundView
{
    UIView *cellSelectedBackgroundView = [[UIView alloc] init];
    cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
    [cellSelectedBackgroundView sizeToFit];
    return cellSelectedBackgroundView;
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    VENetWorkReportingTableViewCell *recommendCell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_NetWorkReport];
    if (recommendCell == nil)
    {
        recommendCell = (VENetWorkReportingTableViewCell *)[[[NSBundle  mainBundle]  loadNibNamed:KIdentifier_NetWorkReport owner:self options:nil]  lastObject];
//        recommendCell.selectedBackgroundView = [self cellSelectedBackgroundView];
        recommendCell.accessoryType = UITableViewCellAccessoryNone;
    }
    recommendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return recommendCell;
}

-(void)setAgent:(NetworkReportingAgent *)agent{
    _agent = agent;
    _titleLabel.text = agent.title;
    _timeLabel.text = agent.orgTime;
    _areaLabel.text = agent.area;
    _stateLabel.text = agent.statusString;
    if (agent.status == 2){
        _stateLabel.textColor = midGreenColor;
    }else if (agent.status == 3){
        _stateLabel.textColor = midRedColor;
    }
    // 已读、未读背景颜色
    NSString *bkImageName = nil;
    if (agent.isRead){
        _titleLabel.textColor = readFontColor;
        bkImageName = kGrayBK;
    }else{
        _titleLabel.textColor = unreadFontColor;
        bkImageName = kWhiteBK;
    }
    _bkView.image = [QCZipImageTool imageNamed:bkImageName];
    _selectedImage = _bkView.image;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        self.bkView.image = _selectedImage;
    }
}
@end
