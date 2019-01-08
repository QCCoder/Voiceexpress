//
//  MenuTableViewCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/23.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MenuTableViewCell.h"

@interface MenuTableViewCell()

@property (weak, nonatomic) UIImageView *icon;

@property (weak, nonatomic) UILabel *titleLabel;

@property (nonatomic,strong) UIColor *selectColor;

@property (nonatomic,strong) UIView *redView;

@end

@implementation MenuTableViewCell


-(UIView *)redView
{
    if (!_redView) {
        UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(Main_Screen_Width * 0.65, 0, 13.0, 13.0)];
//        redView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:redView];
        self.redView = redView;
        
        CAShapeLayer *innerCircleLayer = [[CAShapeLayer alloc] init];
        innerCircleLayer.strokeColor = [UIColor clearColor].CGColor;
        innerCircleLayer.lineWidth = 1.0f;
        innerCircleLayer.fillColor  = RGBCOLOR(250, 111, 111).CGColor;
        innerCircleLayer.frame = CGRectMake(0, 0, 13, 13);
        UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:innerCircleLayer.bounds];
        innerCircleLayer.path = innerPath.CGPath;
        [redView.layer addSublayer:innerCircleLayer];
        
        
    }
    return _redView;
}

+ (UIView *)cellSelectedBackgroundView
{
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 54)];
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(51, 53, Main_Screen_Width - 51, 0.2)];
//    [line setBackgroundColor:RGBCOLOR(100, 100, 100)];
//    [view addSubview:line];
//    [view setBackgroundColor:[UIColor colorWithHexString:Config(Menu_Cell_Selected_Color)]];
    return view;
}


+(id)cellWithTableView:(UITableView *)tableView{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if (cell == nil){
        cell = [[MenuTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithHexString:Config(MainColor)];
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
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 19, 19)];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:icon];
    _icon = icon;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(54, 17, 200, 21)];
    [titleLabel setFont:[UIFont systemFontOfSize:16.5]];
    titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    self.redView.hidden = NO;
    
//    self.innerCircleLayer.frame = CGRectMake;
//    UIImageView *imageNew = [[UIImageView alloc]initWithFrame:CGRectMake(Main_Screen_Width * 0.65, 0, 13.0, 13.0)];
//    
//    imageNew.layer.masksToBounds = YES;
//    imageNew.layer.cornerRadius = 6;
//    [imageNew setBackgroundColor:];
//    [self.contentView addSubview:imageNew];
//    _imageNew = imageNew;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(51, 53, Main_Screen_Width - 51, 0.3)];
    [line setBackgroundColor:RGBCOLOR(100, 100, 100)];
    [self.contentView addSubview:line];
    _line = line;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _icon.ve_centerY = _titleLabel.ve_centerY;
    self.redView.ve_centerY = _titleLabel.ve_centerY;
}

-(void)setMenu:(Menu *)menu{
    _menu = menu;
    self.icon.image = [QCZipImageTool imageNamed:menu.icon];
    _titleLabel.text = menu.title;
    if (menu.hasNew) {
        self.redView.hidden = NO;
    }else{
        self.redView.hidden = YES;
    }
    
    if (menu.isSelected) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:Config(Menu_Cell_Selected_Color)];
    }else{
        self.contentView.backgroundColor = [UIColor colorWithHexString:Config(Menu_Cell_Normal_Color)];
    }
    _selectColor = self.contentView.backgroundColor;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:Config(Menu_Cell_Selected_Color)];
    }else{
        self.contentView.backgroundColor = _selectColor;
    }
}

@end
