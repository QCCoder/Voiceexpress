//
//  VEReplyTableViewCell.m
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEReplyTableViewCell.h"

@interface VEReplyTableViewCell()

@property (nonatomic,weak) UILabel *senderLabel;

@property (nonatomic,weak) UILabel *tipLabel;

@property (nonatomic,weak) UILabel *contentLabel;

@property (nonatomic,weak) UIImageView *bkView;

@property (nonatomic,weak) UILabel *timeLabel;

@end

@implementation VEReplyTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView index:(ReplyIndex)index identifier:(NSString *)identifier{
    VEReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:KNibName_Reply owner:self options:nil] objectAtIndex:index];
        cell.selectedBackgroundView = [VEUtility cellSelectedBackgroundView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.replyBtn.ve_width = Main_Screen_Width - 20;
    self.imageViewBackground.ve_width = self.ve_width;
    self.bkView.ve_width = self.ve_width - 20;
}

+(instancetype)cellWithTableview:(UITableView *)tableView{
    
    VEReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyContentCell"];
    if (!cell) {
        cell = [[VEReplyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReplyContentCell"];
        cell.selectedBackgroundView = [VEUtility cellSelectedBackgroundView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    UILabel *senderLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 8, 90, 20)];
    _senderLabel.textColor = RGBCOLOR(29, 131, 255);
    _senderLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:senderLabel];
    _senderLabel = senderLabel;
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 8, 90, 20)];
    tipLabel.textColor = RGBCOLOR(189, 189, 189);
    tipLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:tipLabel];
    _tipLabel = tipLabel;
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 8, 90, 20)];
    contentLabel.textColor = RGBCOLOR(68, 68, 68);
    contentLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:contentLabel];
    _contentLabel = contentLabel;
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 8, 200, 20)];
    timeLabel.textColor = RGBCOLOR(178, 178, 178);
    timeLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.contentView addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    UIImageView *bkView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 0, 78)];
    bkView.image = [QCZipImageTool imageNamed:@"reply_box.png"];
    [self.contentView addSubview:bkView];
    _bkView = bkView;
    
}

-(void)setAgent:(ReplyAgent *)agent{
    _agent = agent;
    
    self.contentView.backgroundColor = RGBCOLOR(246, 246, 246);
    
    _senderLabel.text = agent.fromName;
    _senderLabel.ve_width = [_senderLabel.text sizeWithAttributes:@{NSFontAttributeName:_senderLabel.font}].width;
    
    _tipLabel.text = agent.showTip;
    _tipLabel.ve_x = CGRectGetMaxX(_senderLabel.frame) + 5;
    
    _contentLabel.text = agent.content;
    _contentLabel.ve_y = CGRectGetMaxY(_senderLabel.frame) + 5;
    _contentLabel.ve_width = Main_Screen_Width - 40;
    _contentLabel.ve_x = 20;
    CGFloat titleH = [agent.content boundingRectWithSize:CGSizeMake(_contentLabel.ve_width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel.font} context:nil].size.height;
    _contentLabel.ve_height = titleH;
    
    
    _timeLabel.text = agent.replyTime;
    _timeLabel.ve_y = CGRectGetMaxY(_contentLabel.frame) + 5;
    
    CGFloat H = titleH + 60;
    if (_addBottomLine) {
        UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"reply_box_line"]];
        bottomImageView.frame = CGRectMake(10.0f, H - 1 ,Main_Screen_Width - 20,1.0f);
        [self.contentView addSubview:bottomImageView];
    }
    
    
    self.imageViewBackground.height = H;
    self.imageViewBackground.width = Main_Screen_Width - 20;
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(10, 0, Main_Screen_Width - 20, H)];
    [view setBackgroundColor:[UIColor whiteColor]];
    [self.contentView insertSubview:view atIndex:0];
}

-(void)setAddBottomLine:(BOOL)addBottomLine{
    _addBottomLine = addBottomLine;
}
@end
