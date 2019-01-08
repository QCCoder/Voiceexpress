//
//  HttpTool.h
//  新浪微博
//
//  Created by apple on 15/5/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpImage.h"
@interface HttpTool : NSObject

typedef void (^SuccessResultBlock)(id JSON,NSInteger result);
typedef void (^ResultInfoBlock)(BOOL success,id JSON);
typedef void (^ResultBlock)(id JSON,NSInteger result,NSString *msg);
typedef void (^SuccessBlock)(id JSON);
typedef void (^FailureBlock)(NSError *error);

//重定义block
typedef void (^PostSuccessBlock)(id JSON);
typedef void (^PostFailureBlock)(NSError *error);
/**
 *  post方法
 *
 *  @param url        接口url
 *  @param parameters 参数
 *  @param success    成功返回JSON
 *  @param failure    返回失败
 */
+(void)postWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters Success:(PostSuccessBlock)success Failure:(PostFailureBlock)failure;


//重定义block
typedef void (^GetSuccessBlock)(id JSON);
typedef void (^GetFailureBlock)(NSError *error);
/**
 *  get方法
 *
 *  @param url        接口Url
 *  @param parameters 参数
 *  @param success    成功返回JSON数据
 *  @param failure    失败信息
 */
+(void)getWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters Success:(GetSuccessBlock)success Failure:(GetFailureBlock)failure;


/**
 *  用session发出POST请求
 *
 *  @param url         接口url
 *  @param param       接口参数
 *  @param success     成功返回数据
 *  @param failure     返回失败数据
 */
+ (void)postWithSessionClient:(NSString *)url param:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;


typedef void (^SessionSuccessBlock)(id JSON);
typedef void (^SessionFailureBlock)(NSError *error);

/**
 *  用session发出Get请求
 *
 *  @param url         接口url
 *  @param param       接口参数
 *  @param success     成功返回数据
 *  @param failure     返回失败数据
 */
+ (void)getWithSessionClient:(NSString *)url param:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure;

+(void)uploadImageWithUrl:(NSString *)url httpImages:(NSArray *)httpImages param:(id)parameters Success:(SuccessBlock)success Failure:(FailureBlock)failure;
/**
 *  网络监测
 */
+(void)checkNetWork;

@end
