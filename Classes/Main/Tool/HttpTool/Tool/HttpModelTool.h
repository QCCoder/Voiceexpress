//
//  HttpModelTool.h
//  GonganNew
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 cyyun.voiceexpress. All rights reserved.

#import <Foundation/Foundation.h>
#import "HttpTool.h"

#pragma mark 重要
//  请求和返回
//  Request 为模型数据
//  Respones 为模型数据
@interface HttpModelTool : NSObject


typedef void (^ModelSuccessBlock)(id model);
/**
 *  get方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)getWithUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(void (^)(NSError *))failure;



/**
 *  post方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)postWithUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(PostFailureBlock)failure;

/**
 *  session的post方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)postSessionDataWithTaskUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(SessionFailureBlock)failure;

/**
 *  session的get方法
 *
 *  @param url         接口url
 *  @param param       参数
 *  @param responseClass 返回值的类，用于封装
 *  @param success     返回成功
 *  @param failure     返回失败
 */
+ (void)getSessionDataWithTaskUrl:(NSString *)url requestModel:(id)requestModel responseClass:(Class)responseClass success:(ModelSuccessBlock)success failure:(SessionFailureBlock)failure;

@end
