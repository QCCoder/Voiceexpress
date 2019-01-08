//
//  DownTool.h
//  GonganNew
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadTool : NSObject

typedef void (^DownSuccessBlock)(id responseObject);
typedef void (^DownSuccessWithPathBlock)(id responseObject,NSString *path);
typedef void (^DownFailureBlock)(NSError *error);
typedef void (^DownProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

//下载
+(instancetype)download;

-(void)downloadFile:(NSString *)UrlAddress Path:(NSString *)path Success:(DownSuccessWithPathBlock)success Failure:(DownFailureBlock)failure  Progress:(DownProgressBlock)progress;
/**
 *  暂停下载
 */
-(void)downloadPause;
/**
 *  重新开始下载
 */
-(void)downloadResume;



//异步加载图片
+ (void)downloadImageWithUrl:(NSString *)url place:(UIImage *)place imageView:(UIImageView *)imageView;

@end
