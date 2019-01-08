//
//  ThemeTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/2.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeTool : NSObject

+(void)loadTheme;

+(void)unzipFileAtPath:(NSString *)filePath toPath:(NSString *)toPath success:(ResultInfoBlock)success;

@end
