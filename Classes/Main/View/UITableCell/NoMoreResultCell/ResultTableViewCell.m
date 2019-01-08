//
//  ResultTableViewCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/24.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "ResultTableViewCell.h"

@interface ResultTableViewCell()

@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,assign) BOOL isNoMoreResult;
@end

@implementation ResultTableViewCell

+(id)cellWithTableView:(UITableView *)tableView isNoMoreResult:(BOOL)isNoMoreResult{
    ResultTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ResultTableViewCell"];
    if (cell == nil){
        cell = [[ResultTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultTableViewCell"];
        cell.backgroundColor = selectedBackgroundColor;
        cell.selectedBackgroundView = [VEUtility cellSelectedBackgroundView];
    }
    cell.isNoMoreResult = isNoMoreResult;
    return cell;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = RGBCOLOR(185, 185, 185);
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return _titleLabel;
}

-(void)setIsNoMoreResult:(BOOL)isNoMoreResult{
    _isNoMoreResult = isNoMoreResult;
    
    if (isNoMoreResult) { //没有更多
        [self setupNoMoreCell];
    }else{//没有内容
        [self setupNoResultCell];
    }
}

/**
 *  没有更多
 */
-(void)setupNoMoreCell{
    self.titleLabel.text = @"没有更多搜索结果";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
}

/**
 *  没有内容
 */
-(void)setupNoResultCell{
    self.titleLabel.text = @"暂无内容";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.contentView.frame;
}

@end
