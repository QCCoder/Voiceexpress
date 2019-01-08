//
//  VEWarnAlertTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEWarnAlertTableViewCell.h"

@interface VEWarnAlertTableViewCell()

@property (nonatomic,strong) UIImage *selectImage;

@end

@implementation VEWarnAlertTableViewCell


+ (UIView *)cellSelectedBackgroundView
{
    UIView *cellSelectedBackgroundView = [[UIView alloc] init];
    cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
    [cellSelectedBackgroundView sizeToFit];
    return cellSelectedBackgroundView;
}

+(id)cellWithTableView:(UITableView *)tableView
{
    VEWarnAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VEWarnAlertTableViewCell"];
    if (cell == nil)
    {
         cell = [[[NSBundle mainBundle] loadNibNamed:@"VEWarnAlertTableViewCell" owner:self options:nil] lastObject];
//        cell.selectedBackgroundView = [self cellSelectedBackgroundView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)setWarnAgent:(WarnAgent *)warnAgent
{
    _warnAgent = warnAgent;
    
    self.labelSiteName.centerX = Main_Screen_Width * 0.5 - 100;
    
    self.labelTitle.text = warnAgent.title;
    self.labelTime.text  = warnAgent.timePost;
    self.labelArea.text  = nil;
    self.labelSiteName.text = nil;
    
    if (warnAgent.localTag.length > 0)
    {
        self.labelArea.text = warnAgent.localTag;
        self.labelArea.textColor = midGreenColor;
    }
    
    if (warnAgent.site.length > 0 && self.labelArea.text == nil)
    {
        self.labelArea.text = warnAgent.site;
        self.labelArea.textColor = detailTitleColor;
    }
    else
    {
        self.labelSiteName.text  = (warnAgent.site.length > 0 ? warnAgent.site : @"");
    }
    
    // 预警等级 1:红色; 2:黄色; 3:蓝色; 其它为绿色.
    NSString *levelImageName = nil;
    switch (warnAgent.warnLevel)
    {
        case 1:
            levelImageName = Config(Icon_List_Red);
            break;
            
        case 2:
            levelImageName = Config(Icon_List_Yellow);
            break;
            
        case 3:
            levelImageName = Config(Icon_List_Blue);
            break;
            
        default:
            levelImageName = Config(Icon_List_Green);
            break;
    }
    self.imageLevel.image = [QCZipImageTool imageNamed:levelImageName];
    // 已读、未读背景颜色
    NSString *bkImageName = nil;
    if (warnAgent.isRead)
    {
        self.labelTitle.textColor = readFontColor;
        bkImageName = kGrayBK;
    }
    else
    {
        self.labelTitle.textColor = unreadFontColor;
        bkImageName = kWhiteBK;
    }
    self.imageBackground.image = [QCZipImageTool imageNamed:bkImageName];
    _selectImage = self.imageBackground.image;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _imageBackground.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        _imageBackground.image = _selectImage;
    }
}
@end
