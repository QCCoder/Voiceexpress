//
//  DetailHeadView.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "DetailHeadView.h"

#define kFont [UIFont boldSystemFontOfSize:15.0]

@interface DetailHeadView()

@property (nonatomic,weak) UILabel *senderLabel;
@property (nonatomic,weak) UILabel *sendTipLabel;

@property (nonatomic,weak) UILabel *receiverTipLabel;

@property (weak, nonatomic) UIButton *receiverCountLabel;
@property (weak, nonatomic) UIButton *receiverImage;

@property (nonatomic,weak) UIView *line;

@property (nonatomic,assign) BOOL show;

@end

@implementation DetailHeadView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *sendTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 4, 50, 21)];
    sendTipLabel.font = kFont;
    sendTipLabel.text = Config(Sender);
    sendTipLabel.textColor = RGBCOLOR(153, 153, 153);
    [self addSubview:sendTipLabel];
    _sendTipLabel = sendTipLabel;
    
    UILabel *senderLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 4, 200, 21)];
    senderLabel.font = kFont;
    senderLabel.textColor = RGBCOLOR(5, 169, 248);
    [self addSubview:senderLabel];
    _senderLabel = senderLabel;
    
    UILabel *receiverTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 33, 50, 21)];
    receiverTipLabel.font = kFont;
    receiverTipLabel.text = Config(Recriver);
    receiverTipLabel.textColor = RGBCOLOR(153, 153, 153);
    [self addSubview:receiverTipLabel];
    _receiverTipLabel = receiverTipLabel;
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(60, 29, 200, 30)];
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.bounces = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    _tableView = tableView;
    
    UIButton *receiverImage = [[UIButton alloc]initWithFrame:CGRectMake(0, 36, 15, 15)];
    [receiverImage setImage:Image(Icon_Arr_Down) forState:UIControlStateNormal];
    [receiverImage setImage:Image(Icon_Arr_Up) forState:UIControlStateSelected];
    [receiverImage addTarget:self action:@selector(showReceiver) forControlEvents:UIControlEventTouchUpInside];
    receiverImage.hidden = YES;
    [self addSubview:receiverImage];
    _receiverImage = receiverImage;
    
    UIButton *receiverCountLabel = [[UIButton alloc]initWithFrame:CGRectMake(0, 33, 50, 21)];
    receiverCountLabel.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    receiverCountLabel.titleLabel.textAlignment = NSTextAlignmentRight;
    [receiverCountLabel setTitleColor:RGBCOLOR(138, 138, 138) forState:UIControlStateNormal];
    [receiverCountLabel addTarget:self action:@selector(showReceiver) forControlEvents:UIControlEventTouchUpInside];
    [receiverCountLabel setImageEdgeInsets:UIEdgeInsetsMake(0, 90, 0, 0)];
    receiverCountLabel.hidden = YES;
    [self addSubview:receiverCountLabel];
    _receiverCountLabel = receiverCountLabel;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(5, 0, Main_Screen_Width - 10, 1)];
    [line setBackgroundColor:RGBCOLOR(170, 170, 170)];
    [self addSubview:line];
    _line = line;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _receiverImage.ve_x = Main_Screen_Width - 7 - _receiverImage.ve_width;
    _receiverCountLabel.ve_width = [_receiverCountLabel.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_receiverCountLabel.titleLabel.font}].width;
    _receiverCountLabel.ve_x = _receiverImage.ve_x - _receiverCountLabel.ve_width + 2;
    _tableView.ve_width = CGRectGetMinX(_receiverCountLabel.frame) - 60 - 2;
    
    if (self.show) {
        self.tableView.ve_height = ((_data.revicers + 1) / 2) * 30;
    }else{
        self.tableView.ve_height = 30;
    }
    
    CGFloat Y = CGRectGetMaxY(_tableView.frame) + 5;
    if (_data.revicers == 0) {
        Y = CGRectGetMaxY(_senderLabel.frame) + 5;

        _receiverTipLabel.hidden = YES;
        _tableView.hidden = YES;
        _receiverImage.hidden = YES;
        _receiverCountLabel.hidden = YES;
    }else{
        _receiverTipLabel.hidden = NO;
        _tableView.hidden = NO;
    }
    _line.ve_y = Y - 3;
    self.ve_height =  Y - 2;
    
    if (self.showList) {
        self.showList(self.ve_height);
    }
}

-(void)setData:(DetilHead *)data{
    _data = data;
    
    _senderLabel.text = data.sender;

    if (data.revicers > 2) {
        [_receiverCountLabel setTitle:[NSString stringWithFormat:@"共%ld人",(long)data.revicers] forState:UIControlStateNormal];
        _receiverCountLabel.hidden = NO;
        _receiverImage.hidden = NO;
    }else{
        _receiverCountLabel.hidden = YES;
        _receiverImage.hidden = YES;
    }
    
    [self setNeedsLayout];
}

-(void)showReceiver{
    
    if (self.show) {
        self.show = NO;
        self.receiverImage.selected = NO;
    }else{
        self.show = YES;
        self.receiverImage.selected = YES;
    }
    [self setNeedsLayout];
}

@end
