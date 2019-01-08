//
//  DES3Util.m
//  DES3
//
//  Created by Yaning Fan on 14-4-8.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "DES3Util.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>

static const NSString *KKey = @"cyyunvoiceexpress$#413#$";
static const NSString *KIv = @"20140413";

@implementation DES3Util

// 加密方法
+ (NSString*)encrypt:(NSString*)plainText
{
    if (plainText.length == 0)
    {
        return @"";
    }
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    // CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [KKey UTF8String];
    const void *vinitVec = (const void *) [KIv UTF8String];
    
    /*ccStatus = */CCCrypt(kCCEncrypt,
                           kCCAlgorithm3DES,
                           kCCOptionPKCS7Padding,
                           vkey,
                           kCCKeySize3DES,
                           vinitVec,
                           vplainText,
                           plainTextBufferSize,
                           (void *)bufferPtr,
                           bufferPtrSize,
                           &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    free(bufferPtr);
    return result;
}

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText
{
    if (encryptText.length == 0)
    {
        return @"";
    }
    
    NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    // CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [KKey UTF8String];
    const void *vinitVec = (const void *) [KIv UTF8String];
    
    /*ccStatus = */CCCrypt(kCCDecrypt,
                           kCCAlgorithm3DES,
                           kCCOptionPKCS7Padding,
                           vkey,
                           kCCKeySize3DES,
                           vinitVec,
                           vplainText,
                           plainTextBufferSize,
                           (void *)bufferPtr,
                           bufferPtrSize,
                           &movedBytes);
    
    NSString *result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                      length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] autorelease];
    free(bufferPtr);
    return result;
}

@end
