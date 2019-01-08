//
//  HttpClient.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HttpClient.h"

NSString *sessionToken;

@implementation HttpClient

+ (instancetype)shareClient
{
    static HttpClient *client = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        client = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL] sessionConfiguration:configuration];
        NSMutableSet *setM =  [client.responseSerializer.acceptableContentTypes mutableCopy];
        [setM addObject:@"text/html"];
        client.responseSerializer.acceptableContentTypes = [setM copy];
        client.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return client;
}

- (void)postWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure{
    
    [self POST:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
        success(response);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
