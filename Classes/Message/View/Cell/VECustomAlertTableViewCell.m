//
//  VECustomAlertTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VECustomAlertTableViewCell.h"

@interface VECustomAlertTableViewCell()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageNew;
@property (strong, nonatomic) IBOutlet UIImageView *imageBackground;
@property (weak, nonatomic) IBOutlet UIView *warnningLevelView;
@property (weak, nonatomic) IBOutlet UILabel *showTitle;


@property (nonatomic,strong) UIImage *selectedImage;
@end

@implementation VECustomAlertTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
   VECustomAlertTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_CustomAlert];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:kNibName_CustomAlert owner:nil options:nil][0];
        cell.backgroundColor = selectedBackgroundColor;
        cell.selectedBackgroundView = [VEUtility cellSelectedBackgroundView];
    }
    return cell;
}

-(void)setAgent:(IntelligenceAgent *)agent{
    _agent = agent;
    //设置标题
    NSString *string = nil;
    if (!agent.levelTip) {
        string = [NSString stringWithFormat:@"%@",agent.title];
    }else {
        string = [NSString stringWithFormat:@"%@%@",agent.title,agent.levelTip];
    }
    if (agent.newestTimeReply > agent.latestTimeReply) {
        if (string.length > 30) {
            string = [string substringToIndex:30];
            string = [NSString stringWithFormat:@"%@...",string];
        }
        NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
        NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setLineSpacing:2];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
        [self.labelTitle setAttributedText:attributedString1];
    }else{
        if (string.length == 0) {
            self.labelTitle.text = agent.showTitle;
        }else{
            self.labelTitle.text = string;
        }

    }
    
    
    self.labelTime.text = [VEUtility formatDateWithTimeInterval:(agent.newestTimeReply * 0.001)];
    if (agent.showTitle.length!=0 && string.length!=0) {
        _showTitle.text = [NSString stringWithFormat:@"  %@",agent.numberTitle];
        _showTitle.textColor = RGBCOLOR(26, 131, 255);
        self.labelAuthor.text = agent.author;
        _showTitle.width = [_showTitle.text sizeWithAttributes:@{NSFontAttributeName:_showTitle.font}].width;
        CGFloat authorW =[self.labelAuthor.text sizeWithAttributes:@{NSFontAttributeName:self.labelAuthor.font}].width;
        CGFloat addW = (CGRectGetMinX(self.labelTime.frame) - CGRectGetMaxX(self.showTitle.frame)) * 0.5;
         self.labelAuthor.frame = CGRectMake(0, self.labelAuthor.frame.origin.y, authorW, self.labelAuthor.frame.size.height);
        self.labelAuthor.centerX = CGRectGetMaxX(_showTitle.frame) + addW;
    }else{
        _showTitle.text = [NSString stringWithFormat:@"  %@",agent.author];
        _showTitle.textColor = self.labelTime.textColor;
        self.labelAuthor.text = @"";
    }
   
    if (agent.newestTimeReply > agent.latestTimeReply) {
        self.imageNew.image = Image(Icon_New);
    }else{
        self.imageNew.image = nil;
    }
    
    _warnningLevelView.backgroundColor = agent.levelColor;
    
    // 新回复
    if (agent.newestTimeReply > agent.localTimeReply && agent.newsTimeReply != 0){
        self.imageNew.image = Image(Icon_Tipnew);
    }else{
        self.imageNew.image = nil;
    }
    
    //已读
    if (agent.isRead){
        self.labelTitle.textColor = readFontColor;
        self.imageBackground.image = Image(Bg_fj_normal);
    }else{//未读
        self.labelTitle.textColor = unreadFontColor;
        self.imageBackground.image = Image(Bg_fj_active);
    }
    _selectedImage = self.imageBackground.image;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:YES];
    self.warnningLevelView.backgroundColor = self.agent.levelColor;
    if (highlighted) {
        self.imageBackground.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        self.imageBackground.image = _selectedImage;
    }
}

@end
