//
//  HttpTool.m
//  新浪微博
//
//  Created by apple on 15/5/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "HttpTool.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "HttpClient.h"
NSString *sessionToken;

@implementation HttpTool

//解析JSON数据
+(id)getJosnWithOperation:(AFHTTPRequestOperation *)operation ResponseObject:(id)responseObject
{
    NSString *requestTmp = [NSString stringWithString:operation.responseString];
    NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    return JSON;
}

/**
 *  拼接公用参数
 *
 *  @param parameters 拼接之前的参数
 *
 *  @return 拼接之后的参数
 */
+(id)addParamters:(NSDictionary *)parameters
{
    NSMutableDictionary *params = nil;
    if (parameters.count == 0) {
        params = [NSMutableDictionary dictionary];
    }else{
        params = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    }
    if (sessionToken.length == 0)
    {
        params[@"sessionToken"] = @"0";
    }else{
        params[@"sessionToken"] = sessionToken;
    }
    
    params[@"deviceInfo"] = [NSString stringWithFormat:@"IOS-%@",[VEUtility getUMSUDID]];
    params[@"br"] = kBranch;
    params[@"version"] = [VEUtility curAppVersion];
    NSLog(@"params : %@", params);
    return params;
}
/**
 *  拼接url基本路径
 *
 *  @return 返回整体url
 */
+(NSString *)appendBaseURL:(NSString *)url
{
    return [kBaseURL stringByAppendingPathComponent:url];
}

/**
 *  POST请求
 *
 *  @param path       POST路径
 *  @param parameters POST参数
 *  @param success    成功返回Block
 *  @param failure    失败返回Block
 */

+(void)postWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters Success:(PostSuccessBlock)success Failure:(PostFailureBlock)failure
{
    url = [self appendBaseURL:url];
    parameters = [self addParamters:parameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //添加参数类型
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];

    //返回值数据JSON
    manager.responseSerializer =[AFJSONResponseSerializer serializer];
    //超时
    manager.requestSerializer.timeoutInterval = 12.0;
    

    NSString *param = @"";
    for (NSString *key in parameters) {
        param = [param stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,parameters[key]]];
    }
    NSLog(@"%@?%@",url,param);
    
    //法搜陪你过POST请求
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //返回JSON
//        DLog(@"HTTP:%@",[self getJosnWithOperation:operation ResponseObject:responseObject]);
        success([self getJosnWithOperation:operation ResponseObject:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%ld %@",[error code],[error localizedDescription]);
        if ([error code] == -1001) {
            [AlertTool showAlertToolWithMessage:@"连接超时"];
        }else{
            [AlertTool showAlertToolWithMessage:@"服务器错误"];
        }
        failure(error);
    }];
}

/**
 *  GET请求
 *
 *  @param path       GET路径
 *  @param parameters GET参数
 *  @param success    成功返回Block
 *  @param failure    失败返回Block
 */
+(void)getWithUrl:(NSString *)url Parameters:(NSDictionary *)parameters Success:(GetSuccessBlock)success Failure:(GetFailureBlock)failure
{
    url = [self appendBaseURL:url];
    parameters = [self addParamters:parameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //添加参数类型
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    manager.responseSerializer =[AFJSONResponseSerializer serializer];
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //返回JSON
        success([self getJosnWithOperation:operation ResponseObject:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

/**
 *  session发送post
 *
 *  @param url     接口url
 *  @param params  接口参数
 *  @param success 成功返回
 *  @param failure 失败返回
 */
+ (void)postWithSessionClient:(NSString *)url param:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *param = @"";
    for (NSString *key in parameters) {
        param = [param stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,parameters[key]]];
    }
    NSLog(@"%@?%@",url,param);
    
    [[HttpClient shareClient] postWithUrl:url Parameters:[self addParamters:parameters] success:^(id JSON) {
        NSInteger result = [JSON[@"result"] integerValue];
        if ( result == 0) {
            success(JSON);
        }else{
            NSError *error = [[NSError alloc]initWithDomain:@"" code:result userInfo:nil];
            [AlertTool showAlertToolWithCode:result];
            failure(error);
        }
    } failure:^(NSError *error) {
        DLog(@"%ld %@",[error code],[error localizedDescription]);
        if ([error code] == -1001) {
            [AlertTool showAlertToolWithMessage:@"连接超时"];
        }else{
            [AlertTool showAlertToolWithMessage:@"服务器错误"];
        };
    }];
}

/**
 *  session发送post
 *
 *  @param url     接口url
 *  @param params  接口参数
 *  @param success 成功返回
 *  @param failure 失败返回
 */
+ (void)getWithSessionClient:(NSString *)url param:(id)parameters success:(SuccessBlock)success failure:(FailureBlock)failure
{
    url = [self appendBaseURL:url];
    parameters = [self addParamters:parameters];
    
    NSURL *requestUrl = [NSURL URLWithString:url];
    //1.设置Configuration来控制是否后台进行标记
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置超时
    configuration.timeoutIntervalForRequest = 10;
    
    //2.获得Session请求管理者
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithBaseURL:requestUrl sessionConfiguration:configuration];
    sessionManager.responseSerializer.acceptableContentTypes =[sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //请求返回数据类型
    //sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //3.用session发出GET请求
    [sessionManager GET:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
/*
    //4.接受完所有所做的操作
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 100, 320, 568)];
    [sessionManager setDataTaskDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        NSURL *baseU = [NSURL URLWithString:@""];
        [webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:baseU];
    }];
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:webView];
*/
}

//监测网络
+(void)checkNetWork
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.baidu.com/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"WAN");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"Wifi");
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"NO");
                break;
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    //开始监控
    [manager.reachabilityManager startMonitoring];
}

+(void)uploadImageWithUrl:(NSString *)url httpImages:(NSArray *)httpImages param:(id)parameters Success:(SuccessBlock)success Failure:(FailureBlock)failure{
    url = [self appendBaseURL:url];
    parameters = [self addParamters:parameters];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (HttpImage *httpImage in httpImages) {
            [formData appendPartWithFileData:httpImage.data name:httpImage.name fileName:httpImage.fileName mimeType:@"image/png"];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success([self getJosnWithOperation:operation ResponseObject:responseObject]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(error);
    }];
}


@end
