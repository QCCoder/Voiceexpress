//
//  PhotoView.m
//  Theme
//
//  Created by 钱城 on 15/12/7.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "PhotoView.h"
#import "ZLPhoto.h"
#import "PhotoButton.h"
#import "UIButton+SD.h"
#import "UIImage+ReMake.h"
#import "UIImageView+SD.h"
#import "UIImage+ZLPhotoLib.h"

#define column 3 //每行三个
#define kMarginW 10
#define kMarginH 10
#define kMarginBorder 0
@interface PhotoView()

@end

@implementation PhotoView

-(NSMutableArray *)assets
{
    if (!_assets) {
        NSMutableArray *assets = [[NSMutableArray alloc]init];
//        [assets addObject:@"http://imgsrc.baidu.com/forum/w%3D580/sign=515dae6de7dde711e7d243fe97eecef4/6c236b600c3387446fc73114530fd9f9d72aa05b.jpg"];
//        [assets addObject:@"http://imgsrc.baidu.com/forum/w%3D580/sign=67ef9ea341166d223877159c76230945/e2f7f736afc3793138419f41e9c4b74543a911b7.jpg"];
//        [assets addObject:@"http://imgsrc.baidu.com/forum/w%3D580/sign=42d17a169058d109c4e3a9bae159ccd0/61f5b2119313b07e550549600ed7912397dd8c21.jpg"];
//        [assets addObject:@"http://imgsrc.baidu.com/forum/w%3D580/sign=a18485594e086e066aa83f4332087b5a/4a110924ab18972bcd1a19a2e4cd7b899e510ab8.jpg"];
//        [assets addObject:@"http://imgsrc.baidu.com/forum/w%3D580/sign=1875d6474334970a47731027a5cbd1c0/51e876094b36acaf9e7b88947ed98d1000e99cc2.jpg"];
        self.assets = assets;
    }
    return _assets;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    [self reloadImageView];
}

- (void)reloadImageView{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat width = (self.frame.size.width - kMarginW * (column - 1 ) - kMarginBorder * 2)  / column;
    CGFloat heigth = width / 80.0  * 60.0;
//    self.backgroundColor = [UIColor redColor];
//    CGFloat width = 80;
//    CGFloat heigth = 60;
    for (int i = 0; i <= self.assets.count; i++) {
        NSInteger row = i / column;
        NSInteger col = i % column;
        PhotoButton *btn = [[PhotoButton alloc]init];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake((width + kMarginW) * col + kMarginBorder, (heigth + kMarginH) * row + kMarginBorder , width, heigth);
        if (i == self.assets.count) {//最后一个按钮
            if (self.assets.count >= kMaxImageCount) {
                return;
            }
            [btn setImage:[UIImage imageNamed:@"icon_image_add.png"] forState:UIControlStateNormal];
            btn.hiddDeleteBtn = YES;
            [btn addTarget:self action:@selector(photoSelect) forControlEvents:UIControlEventTouchUpInside];
            if (self.assets.count >= 6) {
                btn.hidden = YES;
            }
        }else{
            id asset = [self.assets objectAtIndex:i];
            if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
                [btn setImage:[asset thumbImage] forState:UIControlStateNormal];
            }else if([asset isKindOfClass:[NSString class]]){
                [btn imageWithUrlStr:self.assets[i] phImage:nil];
            }else if([asset isKindOfClass:[ZLCamera class]]){
                [btn setImage:[asset thumbImage] forState:UIControlStateNormal];
            }else if([asset isKindOfClass:[UIImage class]]){
                [btn setImage:asset forState:UIControlStateNormal];
            }
            btn.tag = i;
            [btn addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setAdjustsImageWhenHighlighted:NO];
            btn.deleteBtnClick = ^(NSInteger index){
                [self deleteImage:index];
                if (self.deleteImage) {
                    self.deleteImage(index);
                }
            };
        }
        [self addSubview:btn];
    }
}

-(void)photoSelect{
    if(self.addImage){
        self.addImage();
    }
}

-(void)addImageWithNSArray:(NSArray *)array
{
    [self.assets addObjectsFromArray:array];
    [self setNeedsLayout];
}

-(void)photoClick:(UIButton *)btn
{
    if (self.clickImage) {
        self.clickImage(btn,btn.tag);
    }
}

-(void)deleteImage:(NSInteger)index{
    [self.assets removeObjectAtIndex:index];
    [self setNeedsLayout];
}
@end
