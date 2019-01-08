//
//  FYNHttpRequestLoader.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYNHttpRequestLoader : NSObject

@property (nonatomic, copy) void (^completionHandler)(NSDictionary *resultData, NSString *error);

- (void)startAsynRequestWithURL:(NSURL *)url;
- (void)startAsynRequestWithURL:(NSURL *)url withParams:(NSString *)paramStr;

- (NSData *)startSynRequestWithURL:(NSURL *)url withTimeOut:(NSInteger)timeOut;
- (NSData *)startSynRequestWithURL:(NSURL *)url withParams:(NSString *)paramStr withTimeOut:(NSInteger)timeOut;

- (void)startAsynUploadWithURL:(NSURL *)url withImages:(NSArray *)imagesList;

- (void)cancelAsynRequest;

@end
