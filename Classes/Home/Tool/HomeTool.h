//
//  HomeTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/20.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeTool : NSObject

+(void)loadHomeTypeListWithTypeId:(NSString *)typeId resultInfo:(ResultInfoBlock)resultInfo;

@end
