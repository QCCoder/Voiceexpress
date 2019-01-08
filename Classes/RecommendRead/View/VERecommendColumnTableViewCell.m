//
//  VERecommendColumnTableViewCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VERecommendColumnTableViewCell.h"

@interface VERecommendColumnTableViewCell()

@property (nonatomic,strong) UIImageView *imageBackground;

@property (nonatomic,strong) UIImage *selectImage;

@end

@implementation VERecommendColumnTableViewCell

+(UIView *)seledBackground
{
    UIView *cellSelectedBackgroundView = [[UIView alloc] init];
    cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
    [cellSelectedBackgroundView sizeToFit];
    return cellSelectedBackgroundView;
}

+ cellWithTableView:(UITableView*)tableView agent:(RecommendAgent *)agent
{
    NSString *cellIdentifier = KIdentifier_RecommendReadNoPics;
    NSInteger index = VERecommendReadTableViewCellNoPicsIndex;
    if (agent.thumbImageUrl.length > 0)
    {
        index = VERecommendReadTableViewCellHasPicsIndex;
        cellIdentifier = KIdentifier_RecommendReadHasPics;
    }
    
    VERecommendColumnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:KNibName_RecommendColumn owner:self options:nil];
        cell = [cellNib objectAtIndex:index];
        cell.selectedBackgroundView = [self seledBackground];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.agent = agent;
    return cell;
}

-(void)setAgent:(RecommendAgent *)agent
{
    _agent = agent;
    
    UILabel *cellLableTitle = nil;
    
    if (agent.thumbImageUrl.length > 0) {
        self.labelHasPicsMain.text = agent.title;
        cellLableTitle = self.labelNoPicsMain;
        self.labelHasPicsTime.text = agent.timePost;
        _imageBackground = self.imageHasPicsBackground;
        
        [self.imageThumb imageWithUrlStr:agent.thumbImageUrl phImage:Image(Icon_Picture_Min)];

    }else{
        self.labelNoPicsMain.text = agent.title;
        cellLableTitle = self.labelNoPicsMain;
        self.labelNoPicsTime.text  = agent.timePost;
        _imageBackground = self.imageNoPicsBackground;
    }
    // 已读、未读背景颜色
    NSString *bkImageName = nil;
    if (agent.isRead)
    {
        cellLableTitle.textColor = readFontColor;
        bkImageName = kGrayBK;
    }
    else
    {
        cellLableTitle.textColor = unreadFontColor;
        bkImageName = kWhiteBK;
    }
    _imageBackground.image = [QCZipImageTool imageNamed:bkImageName];
    _selectImage = _imageBackground.image;
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
