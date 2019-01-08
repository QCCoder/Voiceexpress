//
//  DownTool.m
//  GonganNew
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "DownloadTool.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface DownloadTool()
@property(strong,nonatomic) AFHTTPRequestOperation *operation;
@end

@implementation DownloadTool

+(instancetype)download
{
    DownloadTool *httpTool = [[DownloadTool alloc]init];
    return httpTool;
}

/**
 *  文件下载
 *
 *  @param UrlAddress 下载路径
 *  @param path       沙盒路径
 */
-(void)downloadFile:(NSString *)UrlAddress Path:(NSString *)path Success:(DownSuccessWithPathBlock)success Failure:(DownFailureBlock)failure Progress:(DownProgressBlock)progress
{
    //建立HTTP请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:UrlAddress]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _operation = operation;
    //开始下载
    path = [kDocumentsDirectory stringByAppendingPathComponent:path];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    //下载结果
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DownLoad_Seccess");
        ALERT(@"提示", @"下载成功");
        success(responseObject,path);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"DownLoad_Fail");
        ALERT(@"提示", @"下载失败");
        failure(error);
    }];
    
    //下载状态监控
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progress(bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    [operation start];
}
/**
 *  暂停下载
 */
-(void)downloadPause
{
    [_operation pause];
}
/**
 *  重新开始下载
 */
-(void)downloadResume
{
    [_operation resume];
}


/**
 *  下载图片
 *
 *  @param url       网络图片路径
 *  @param place     默认图片
 *  @param imageView 显示的图片
 */
+ (void)downloadImageWithUrl:(NSString *)url place:(UIImage *)place imageView:(UIImageView *)imageView
{
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:place options:SDWebImageLowPriority | SDWebImageRetryFailed];
}

@end
