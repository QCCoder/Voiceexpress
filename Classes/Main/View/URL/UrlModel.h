//
//  UrlModel.h
//  voiceexpress
//
//  Created by 钱城 on 16/2/1.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlModel : NSObject


+(NSString *)urlContent:(NSString *)content;
+(NSString *)addScheme:(NSString *)url;

@end
