//
//  DetailLabel.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "DetailLabel.h"

@interface DetailLabel()

@property (nonatomic,assign) CGFloat labelWidth;

@end

@implementation DetailLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _labelWidth = Main_Screen_Width - frame.origin.x * 2;
    }
    return self;
}



-(void)setText:(NSString *)text{
    if (text.length == 0) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:LINESPACE];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[VEUtility contentFontSize]] range:NSMakeRange(0, [text length])];
    self.attributedText = attributedString;
    
    [self refreshFrame];
}

-(void)refreshFrame{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:LINESPACE];//调整行间距
    UIFont *font = [UIFont systemFontOfSize:[VEUtility contentFontSize]];
    self.ve_size = [self.text boundingRectWithSize:CGSizeMake(_labelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
}
@end
