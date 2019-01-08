//
//  HttpClient.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface HttpClient : AFHTTPSessionManager

+ (instancetype)shareClient;

- (void)postWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)getWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
