//
//  VERecommendReadTableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VERecommendReadTableViewCell.h"

@interface VERecommendReadTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bkView;

@end

@implementation VERecommendReadTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    VERecommendReadTableViewCell *recommendCell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_RecommendRead];
    if (recommendCell == nil){
        recommendCell = (VERecommendReadTableViewCell *)[[[NSBundle  mainBundle]  loadNibNamed:KIdentifier_RecommendRead owner:self options:nil]  lastObject];
        recommendCell.accessoryType = UITableViewCellAccessoryNone;
    }
    recommendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return recommendCell;
}

-(void)setAgent:(RecommendColumnAgent *)agent
{
    _agent = agent;
    
    self.labelMain.text = agent.columnTitle;
    self.labelMain.textColor = unreadFontColor;
    
    if (agent.localNewestArticleId < agent.newestArticleId){
        self.imageNew.image = Image(Icon_New);
    }else{
        self.imageNew.image = nil;
    }
    [self.imageTip imageWithUrlStr:agent.iconURL phImage:Image(Read_Icon_Default)];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        
        _bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-old.png"];
    }else{
        _bkView.image = [QCZipImageTool imageNamed:@"bar-listbg-new.png"];
    }
}
@end

