//
//  FYNHttpRequestLoader.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "FYNHttpRequestLoader.h"

NSString *sessionToken;
NSString * kAppVersion;
BOOL isTopLeader;

static NSString * const kErrorDataEmpty       = @"服务器返回的数据为空.";
static NSString * const kErrorDataWrongFormat = @"服务器返回的数据格式错误: ";

@interface FYNHttpRequestLoader ()

@property (nonatomic, strong) NSMutableData   *mutableData;
@property (nonatomic, strong) NSURLConnection *urlConnection;

@end

@implementation FYNHttpRequestLoader

@synthesize completionHandler;
@synthesize mutableData;
@synthesize urlConnection;

// 异步方法
- (void)startAsynRequestWithURL:(NSURL *)url
{
    [self startAsynRequestWithURL:url withParams:@""];
}

- (void)startAsynRequestWithURL:(NSURL *)url withParams:(NSString *)paramStr
{
    @autoreleasepool {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        if (paramStr != nil)
        {
            [request setHTTPMethod:@"POST"];
            if (sessionToken.length == 0)
            {
                sessionToken = @"0";
            }
            paramStr = [paramStr stringByAppendingFormat:@"&sessionToken=%@&br=%@&version=%@", sessionToken, kBranch, kAppVersion];
            [request setHTTPBody:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            [request setHTTPMethod:@"GET"];
        }
        [request setTimeoutInterval:20];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.urlConnection = conn;
        
        if ([url.absoluteString rangeOfString:@"CustomWarnAddForGA"].location == NSNotFound)
        {
            NSLog(@"%@?%@", url, paramStr);
        }
        else
        {
            NSLog(@"%@ | ...", url);
        }
//        DLog(@"%@?%@", url, paramStr);
    }
}

// 同步方法

- (NSData *)startSynRequestWithURL:(NSURL *)url withTimeOut:(NSInteger)timeOut
{
    return [self startSynRequestWithURL:url withParams:nil withTimeOut:timeOut];
}

- (NSData *)startSynRequestWithURL:(NSURL *)url withParams:(NSString *)paramStr withTimeOut:(NSInteger)timeOut;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (paramStr != nil)
    {
        [request setHTTPMethod:@"POST"];
        if (sessionToken.length == 0)
        {
            sessionToken = @"0";
        }
        paramStr = [paramStr stringByAppendingFormat:@"&sessionToken=%@&br=%@&veVersion=%@", sessionToken, kBranch, kAppVersion];
        [request setHTTPBody:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    
    if (timeOut <= 0)
    {
        timeOut = 10;
    }
    [request setTimeoutInterval:timeOut];
    
//    DLog(@"%@ | %@", url, paramStr);
    
    NSHTTPURLResponse *httpURLResponse = nil;
    NSError *error = nil;
    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&httpURLResponse
                                                            error:&error];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error != nil)
    {
//        DLog(@"error: %@", [error localizedDescription]);
    }
    if (200 == httpURLResponse.statusCode)
    {
        return receiveData;
    }
    else
    {
//        NSInteger stateCode = [httpURLResponse statusCode];
//        NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:stateCode];
    }
    return nil;
}

// 异步上传图片方法
- (void)startAsynUploadWithURL:(NSURL *)url withImages:(NSArray *)imagesList
{
    @autoreleasepool {
        
        // 分界线的标识符
        NSString *boundary = @"AaB03x";
        // 分界线 --AaB03x
        NSString *MPboundary = [NSString stringWithFormat:@"--%@", boundary];
        // 结束符
        NSString *endMPboundary = [NSString stringWithFormat:@"%@--", MPboundary];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        self.mutableData = [NSMutableData data];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval:300];
        
        // 设置Header
        [request setValue:@"" forHTTPHeaderField:@"X-Upload-File-Name"];
        NSString *content = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:content forHTTPHeaderField:@"Content-Type"];
        
        // 设置Body
        NSMutableData *allBodyData = [NSMutableData data];
        NSInteger index = 0;
        // 添加图像
        for (NSString *singleImagePath in imagesList)
        {
            @autoreleasepool {
                ++index;
                if (singleImagePath.length > 0)
                {
                    NSString *body = [NSString string];
                    
                    // 添加分界线，并换行
                    body = [body stringByAppendingFormat:@"%@\r\n", MPboundary];
                    
                    // 声明字段和文件类型
                    body = [body stringByAppendingFormat:@"Content-Disposition: form-data; name=\"pic%ld\"; filename=\"pic%ld.png\"\r\n", (long)index, index];
                    body = [body stringByAppendingString:@"Content-Type: image/png\r\n\r\n"];
                    
                    [allBodyData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    // 添加图像流
                    NSData *imageData = [NSData dataWithContentsOfFile:singleImagePath];
                    [allBodyData appendData:imageData];
                    
                    [allBodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
        // 添加结束符
        [allBodyData appendData:[endMPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:allBodyData];
        
        NSUInteger postLength = [allBodyData length];
        DLog(@"--- body size: %ld ---", (unsigned long)postLength);
        [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)postLength] forHTTPHeaderField:@"Content-Length"];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        self.urlConnection = conn;
        DLog(@"%@", url);
    }
}

- (void)cancelAsynRequest
{
    @autoreleasepool {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.urlConnection cancel];
        
        self.completionHandler = nil;
        self.urlConnection = nil;
        self.mutableData = nil;
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @autoreleasepool {
        self.mutableData = nil;
        self.mutableData = [NSMutableData data];
        if (response != nil)
        {
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
            NSInteger stateCode = [httpURLResponse statusCode];
            NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:stateCode];
            
            DLog(@"stateCode: %ld, description: %@.", (long)stateCode, description);
        }
        else
        {
            DLog(@"no response");
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @autoreleasepool {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *errorDiscrip = [error localizedDescription];
//        DLog(@"error: %@", errorDiscrip);
        
        if (self.completionHandler)
        {
            self.completionHandler(nil, errorDiscrip);
        }
        self.completionHandler = nil;
        self.urlConnection = nil;
        self.mutableData = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @autoreleasepool {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *severErrorMsg = nil;
        NSError *error = nil;
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:self.mutableData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if (resultDic == nil)
        {
            if (error)
            {
                severErrorMsg = [error localizedDescription];
            }
            else
            {
                severErrorMsg = kErrorDataEmpty;
            }
        }
        else
        {
            if ([resultDic count] < 1)
            {
                severErrorMsg = [NSString stringWithFormat:@"%@%@.", kErrorDataWrongFormat, resultDic];
            }
        }
        
        if (self.completionHandler)
        {
            self.completionHandler(resultDic, severErrorMsg);
        }
        self.completionHandler = nil;
        self.urlConnection = nil;
        self.mutableData = nil;
    }
}

@end
