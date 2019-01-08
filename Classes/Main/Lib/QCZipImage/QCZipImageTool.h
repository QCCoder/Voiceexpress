//
//  QCZipImageTool.h
//  Theme
//
//  Created by apple on 15/11/23.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCZipImage.h"

@interface QCZipImageTool : NSObject

/**
 *  保存配置
 *
 *  @param account 配置
 */
+(void)saveAccount:(QCZipImage *)account;


/**
 *  读取配置
 *
 *  @return 配置
 */
+(QCZipImage *)zipImage;

/**
 *  获取图片资源
 *
 *  @param name 图片名称
 *
 *  @return 图片UIImage
 */
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageOrNamed:(NSString *)name;
+(NSString *)getPath:(NSString *)name;
+(NSDictionary *)getDictionaryWithName:(NSString *)name;
/**
 *  解压文件
 *
 *  @param fileName 文件名称
 */
+ (void)unzipFileToDocument:(NSString *)fileName;

+ (void)moveFileToDocument:(NSString *)fileName type:(NSString *)fileType filePath:(NSString *)filePath;

+(void)unzipFileAtPath:(NSString *)filePath toPath:(NSString *)toPath success:(ResultInfoBlock)success;
@end
