//
//  VECustomAlertTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VECustomAlertTableViewCell.h"

@implementation VECustomAlertTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.warnningLevelView.layer.cornerRadius = 2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



+(instancetype)cellWithTableView:(UITableView *)tableView WithBackgroundView:(UIView *)selectedBackgroundView{
    
   VECustomAlertTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_CustomAlert];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:kNibName_CustomAlert owner:nil options:nil][0];
        cell.backgroundColor = selectedBackgroundColor;
        cell.selectedBackgroundView = selectedBackgroundView; 
    }
    
    return cell;
}

-(void)setAgent:(IntelligenceAgent *)agent{
    _agent = agent;
  
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
    if (agent.showTitle.length!=0 && string.length !=0) {
        _showTitle.text = [NSString stringWithFormat:@"  %@",agent.numberTitle];
        _showTitle.textColor = RGBCOLOR(26, 131, 255);
        self.labelAuthor.text = agent.author;
        
        
        CGFloat W = [_showTitle.text sizeWithFont:_showTitle.font].width;
        _showTitle.width = W;
        CGFloat authorW =[self.labelAuthor.text sizeWithFont:self.labelAuthor.font].width;
        CGFloat addW = (CGRectGetMinX(self.labelTime.frame) - CGRectGetMaxX(self.showTitle.frame)) * 0.5;
         self.labelAuthor.frame = CGRectMake(0, self.labelAuthor.frame.origin.y, authorW, self.labelAuthor.frame.size.height);
        self.labelAuthor.centerX = CGRectGetMaxX(_showTitle.frame) + addW;
    }else{
        _showTitle.text = [NSString stringWithFormat:@"  %@",agent.author];
        _showTitle.textColor = self.labelTime.textColor;
        self.labelAuthor.text = @"";
    }
   
    
    
    if (agent.newestTimeReply > agent.latestTimeReply) {
        self.imageNew.image = [UIImage imageNamed:@"ico-new"];
    }else{
        self.imageNew.image = nil;
    }
    
    _warnningLevelView.backgroundColor = agent.levelColor;
    self.labelTitle.textColor = unreadFontColor;
    self.imageBackground.image = [UIImage imageNamed:kBoxActiveBK];
}



-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:YES];
    self.warnningLevelView.backgroundColor = self.agent.levelColor;
}
@end
