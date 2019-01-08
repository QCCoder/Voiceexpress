//
//  PhotoView.h
//  Theme
//
//  Created by 钱城 on 15/12/7.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMaxImageCount 9

@interface PhotoView : UIView

@property (nonatomic,strong) NSMutableArray *assets;

@property (nonatomic,copy) void (^addImage)();//点击添加照片

@property (nonatomic,copy) void (^clickImage)(id view,NSInteger index);

@property (nonatomic,copy) void(^deleteImage)(NSInteger index);

-(void)addImageWithNSArray:(NSArray *)array;
@end
