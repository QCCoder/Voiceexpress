//
//  VEInternetTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/24.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VEInternetRequest.h"
#import "Articledetail.h"

typedef void (^InternetSuccessBlock)(id JSON);
typedef void (^InternetFailureBlock)(NSError *error);

@interface VEInternetTool : NSObject

//Http请求sessionDataPostWithParams
+ (void)getInternetInfoWithParam:(VEInternetRequest *)params success:(InternetSuccessBlock)success failure:(InternetFailureBlock)failure;

+(void)loadArticleContentWithParamters:(NSDictionary *)request success:(SuccessBlock)success failure:(FailureBlock)failure;
@end
