//
//  QCZipImage.h
//  Theme
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 cyyun.voiceexpress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

#define kTHEME_TAG @"selectTheme"
#define kTHEMEFOLD_TAG @"selectThemeFold"

@interface QCZipImage : NSObject<NSCoding>

//文件名
@property (nonatomic,copy) NSString *fileName;

//文件名
@property (nonatomic,copy) NSString *toPath;

//主题ID
@property (nonatomic,copy) NSString *themeID;

@property (nonatomic,copy) NSString *themeImg;

-(instancetype)initWithNSDictionary:(NSDictionary *)dict;
@end
