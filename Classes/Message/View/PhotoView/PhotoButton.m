//
//  PhotoButton.m
//  Theme
//
//  Created by 钱城 on 15/12/7.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "PhotoButton.h"
#import "UIImage+ZLPhotoLib.h"
@interface PhotoButton()

@property (nonatomic,weak) UIButton *deleteBtn;

@end

@implementation PhotoButton

-(UIButton *)deleteBtn{
    if (!_deleteBtn) {
        UIButton *deleteBtn = [[UIButton alloc]init];
        [deleteBtn setImage:[UIImage ml_imageFromBundleNamed:@"del_icon"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        self.deleteBtn = deleteBtn;
    }
    return _deleteBtn;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat W = 18;
    self.deleteBtn.frame = CGRectMake(self.frame.size.width - W, 0, W, W);
    
    self.imageView.frame = CGRectMake(0, kImageMargin, self.frame.size.width - kImageMargin, self.frame.size.height - kImageMargin);
}

-(void)setHiddDeleteBtn:(BOOL)hiddDeleteBtn{
    _hiddDeleteBtn = hiddDeleteBtn;
    self.deleteBtn.hidden = hiddDeleteBtn;
}

-(void)deleteClick{
    if (self.deleteBtnClick) {
        self.deleteBtnClick(self.tag);
    }
}
@end
