//
//  HttpModelTool.m
//  GonganNew
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.
//

#import "HttpModelTool.h"
#import "MJExtension.h"
@implementation HttpModelTool

/**
 *  get方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)getWithUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(void (^)(NSError *))failure
{
    //把模型转换成数据字典
    NSDictionary *params = [requestModel keyValues];
    //发送get请求
    [HttpTool getWithUrl:url Parameters:params Success:^(id JSON) {
        //解析字典数据成模型数据
        id response = [responseClass objectWithKeyValues:JSON];
        success(response);
        
    } Failure:^(NSError *error) {
        failure(error);
    }];
}

/**
 *  get方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)postWithUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(PostFailureBlock)failure
{
    //把模型转换成数据字典
    NSDictionary *params = [requestModel keyValues];
    //发送get请求
    [HttpTool postWithUrl:url Parameters:params Success:^(id JSON) {
        //解析字典数据成模型数据
        id response = [responseClass objectWithKeyValues:JSON];
        success(response);
    } Failure:^(NSError *error) {
        failure(error);
    }];
}

+(void)postSessionDataWithTaskUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(SessionFailureBlock)failure
{
    //把模型转换成数据字典
    NSDictionary *params = [requestModel keyValues];
    //发送get请求
    [HttpTool postWithSessionClient:url param:params success:^(id JSON) {
        //解析字典数据成模型数据
        id response = [responseClass objectWithKeyValues:JSON];
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+(void)getSessionDataWithTaskUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(SessionFailureBlock)failure
{
    //把模型转换成数据字典
    NSDictionary *params = [requestModel keyValues];
    
    [HttpTool getWithSessionClient:url param:params success:^(id JSON) {
        //解析字典数据成模型数据
        id response = [responseClass objectWithKeyValues:JSON];
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


@end
