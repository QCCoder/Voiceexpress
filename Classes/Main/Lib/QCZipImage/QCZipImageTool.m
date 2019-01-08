//
//  QCZipImageTool.m
//  Theme
//
//  Created by apple on 15/11/23.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "QCZipImageTool.h"
#import "QCZipImage.h"
#import "SSZipArchive.h"
#import "NSString+MJ.h"
#import "UIImage+PDF.h"
// 文件路径
#define kImageFile [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"image.config"]

@implementation QCZipImageTool

/**
 *  保存配置
 *
 *  @param account 配置
 */
+(void)saveAccount:(QCZipImage *)account{
    NSLog(@"Save");
    account.toPath = @"Theme";
    [NSKeyedArchiver archiveRootObject:account toFile:kImageFile];
}


/**
 *  读取配置
 *
 *  @return 配置
 */
+(QCZipImage *)zipImage{
    // 加载模型
    QCZipImage *account = [NSKeyedUnarchiver unarchiveObjectWithFile:kImageFile];
    return account;
}



/**
 *  获取图片资源
 *
 *  @param name 图片名称
 *
 *  @return 图片UIImage
 */
+ (UIImage *)imageNamed:(NSString *)name;
{
    if (name.length == 0) {
        return nil;
    }
    
    if ([[name pathExtension] isEqualToString:@""]) {
        name = [name stringByAppendingString:@".png"];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *themePath = [kDocumentsDirectory stringByAppendingPathComponent:@"Theme"];
    
    if ([[name pathExtension] isEqualToString:@"pdf"]) {
        NSString *pdfPath = [themePath stringByAppendingPathComponent:name];
        if (pdfPath.length > 0  && [fileManager fileExistsAtPath:pdfPath]) {
            return [UIImage imageHalfPDFWithContentsOfFile:pdfPath];
        }else{
            pdfPath = PATH(name, nil);
            return [UIImage imageHalfPDFWithContentsOfFile:pdfPath];
        }
    }
    
    if (IS_RETINA_3) {//@3x
        NSString *imageName3 = [name fileAppend:@"@3x"];
        NSString *path3 = [themePath stringByAppendingPathComponent:imageName3];
        if (path3.length > 0 && [fileManager fileExistsAtPath:path3]) {
            return [UIImage imageWithContentsOfFile:path3];
        }
    }
    
    NSString *imageName2 = [name fileAppend:@"@2x"];
    NSString *path2 = [themePath stringByAppendingPathComponent:imageName2];
    if (path2.length > 0 && [fileManager fileExistsAtPath:path2]) {
        return [UIImage imageWithContentsOfFile:path2];
    }
    
    NSString *path1 = [themePath stringByAppendingPathComponent:name];
    if (path1.length > 0 && [fileManager fileExistsAtPath:path1]) {
        UIImage *image =[UIImage imageWithContentsOfFile:path1];
        return image;
    }
    return [UIImage imageNamed:name];
}

/**
 *  获取图片资源
 *
 *  @param name 图片名称
 *
 *  @return 图片UIImage
 */
+ (UIImage *)imageOrNamed:(NSString *)name;
{
    if (name.length == 0) {
        return nil;
    }
    
    if ([[name pathExtension] isEqualToString:@""]) {
        name = [name stringByAppendingString:@".png"];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *themePath = [kDocumentsDirectory stringByAppendingPathComponent:@"Theme"];
    
    if ([[name pathExtension] isEqualToString:@"pdf"]) {
        NSString *pdfPath = [themePath stringByAppendingPathComponent:name];
        if (pdfPath.length > 0  && [fileManager fileExistsAtPath:pdfPath]) {
            return [UIImage imageOrPDFWithContentsOfFile:pdfPath];
        }else{
            pdfPath = PATH(name, nil);
            return [UIImage imageOrPDFWithContentsOfFile:pdfPath];
        }
    }
    
    if (IS_RETINA_3) {//@3x
        NSString *imageName3 = [name fileAppend:@"@3x"];
        NSString *path3 = [themePath stringByAppendingPathComponent:imageName3];
        if (path3.length > 0 && [fileManager fileExistsAtPath:path3]) {
            return [UIImage imageWithContentsOfFile:path3];
        }
    }
    
    NSString *imageName2 = [name fileAppend:@"@2x"];
    NSString *path2 = [themePath stringByAppendingPathComponent:imageName2];
    if (path2.length > 0 && [fileManager fileExistsAtPath:path2]) {
        return [UIImage imageWithContentsOfFile:path2];
    }
    
    NSString *path1 = [themePath stringByAppendingPathComponent:name];
    if (path1.length > 0 && [fileManager fileExistsAtPath:path1]) {
        UIImage *image =[UIImage imageWithContentsOfFile:path1];
        return image;
    }
    return [UIImage imageNamed:name];
}


+(NSDictionary *)getDictionaryWithName:(NSString *)name{
    NSString *path = [self getPath:name];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+(NSString *)getPath:(NSString *)name{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *themePath = [kDocumentsDirectory stringByAppendingPathComponent:@"Theme"];
    NSString *path = [themePath stringByAppendingPathComponent:name];
    if (path.length > 0 && [fileManager fileExistsAtPath:path]) {
    }else{
        path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    }
    return path;
}
/**
 *  解压文件
 *
 *  @param fileName 文件名称
 */
+ (void)unzipFileToDocument:(NSString *)fileName
{
    //资源文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    [QCZipImageTool moveFileToDocument:fileName type:@"zip" filePath:filePath];
}

/**
 *  将文件移动到Document目录下，并且解压文件
 *
 *  @param fileName 文件路径
 *  @param fileType 文件类型
 */
+ (void)moveFileToDocument:(NSString *)fileName type:(NSString *)fileType filePath:(NSString *)filePath
{
    //存放目录文件路径
    NSString *filePath2 = [kDocumentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:fileType]];
    NSString *pathFold = [filePath2 stringByDeletingPathExtension];
    NSString *path = [kDocumentsDirectory stringByAppendingPathComponent:[QCZipImageTool zipImage].toPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:pathFold]){
        //判断是否移动成功，这里文件不能是存在的
        NSError *thiserror = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:filePath2 error:&thiserror]){//移动文件失败
            NSLog(@"move fail...");
            NSLog(@"Unable to move file: %@", [thiserror localizedDescription]);
        }
        
        //移动文件成功
        //解压文件
        if ([SSZipArchive unzipFileAtPath:filePath2 toDestination:path]) {//解压成功
            NSLog(@"Zip文件解压成功");
        }else{
            NSLog(@"Zip文件解压失败");
        }
        [manager removeItemAtPath:filePath2 error:nil];
        //移除Zip文件
        [manager removeItemAtPath:filePath2 error:nil];
    }
    
}

+(void)unzipFileAtPath:(NSString *)filePath toPath:(NSString *)toPath success:(ResultInfoBlock)success{
    [[NSFileManager defaultManager] removeItemAtPath:[toPath stringByAppendingPathComponent:@"Theme"] error:nil];
    if ([SSZipArchive unzipFileAtPath:filePath toDestination:toPath]) {//解压成功
        NSLog(@"Zip文件解压成功");
        success(YES,nil);
    }else{
        success(NO,nil);
        NSLog(@"Zip文件解压失败");
    }
}
@end
