//
//  UIImageView+load.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/18.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "UIImageView+load.h"

extern BOOL kIsCurrentNetWorkWifi;

@implementation UIImageView (load)


- (void)loadImageWithURL:(NSString *)url
{
    if (!kIsCurrentNetWorkWifi &&
        [VEUtility shouldReceivePictureOnCellNetwork]){
        // 当前网络是WWAN, 并且在2G/3G网络下不允许自动接收图片
        self.image = Image(Icon_Picture_Min);
    }else{
        [self imageWithUrlStr:url phImage:Image(Icon_Picture_Min)];
    }
}

@end
