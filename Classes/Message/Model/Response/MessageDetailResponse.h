//
//  MessageDetailResponse.h
//  voiceexpress
//
//  Created by 钱城 on 16/3/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Receiver.h"
@interface MessageDetailResponse : NSObject


@property (nonatomic,strong) NSArray *receivers;

@property (nonatomic,strong) NSArray *imageUrls;

@property (nonatomic,copy) NSString *content;

@property (nonatomic,copy) NSString *proposals;

@property (nonatomic,copy) NSString *suggestId;

@end
