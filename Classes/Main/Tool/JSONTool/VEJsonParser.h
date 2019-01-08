//
//  VEJsonParser.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-27.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEJsonParser : NSObject

- (id)initWithJsonDictionary:(NSDictionary *)aJsonDicValue;

- (NSInteger)retrieveUGroupIDValue;
- (NSString *)retrieveSessionTokenValue;
- (BOOL)retrieveIsDefaultPasswordValue;
- (BOOL)retrieveIsSecurityCtrlOpenValue;
- (BOOL)retrieveIsLockCtrlOpenValue;
- (BOOL)retrieveIsIntelligenceNeedWholeValue;
- (BOOL)retrieveNetworkReportReviewValue;
- (NSString *)retrieveProposalsValue;
- (NSString *)retrieveProposalsValueId;
- (NSInteger)retrieveRusultValue;
- (NSInteger)retrieveSizeValue;
- (NSArray *)retrieveListValue;
- (NSInteger)retrieveCountValue;
- (NSInteger)retrieveLIDValue;
- (NSInteger)retrieveUIDValue;
- (NSInteger)retrieveGIDValue;
- (BOOL)retrieveFavoriteStateValue;
- (NSString *)retrieveContentValue;
- (NSArray *)retrieveImageUrlsValue;
- (NSArray *)retrieveImagesValues;
- (void)reportErrorMessage;

- (BOOL)retrieveAutoPushValue;
- (BOOL)retrieveNightNoDisturbValue;
- (BOOL)retrievePushGenralAlertValue;
- (BOOL)retrievePushSeriousAlertValue;
- (BOOL)retrievePushUrgentAlertValue;

- (NSInteger)retrieveNewInBoxSizeValue;
- (NSInteger)retrieveNewOutBoxSizeValue;

- (NSString *)retrieveReceiverNames;
- (NSString *)retrieveReceiverReadState;

- (void)printOutServerErrorMessage;
- (NSString *)retrieveServerErrorMessageValue;

- (NSArray *)retrieveToMeReplyListValue;
- (NSArray *)retrieveRelativeMeReplyListValue;

- (BOOL)retrieveMandatoryUpdateValue;
- (NSString *)retrieveUpdateDiscriptionValue;

- (NSArray *)retrieveInternetAreaListValue;
- (NSArray *)retrieveInternetTypeListValue;
- (NSArray *)retrieveInternetOrganizeListValue;

- (NSArray *)retrievelocalTagsValue;

- (NSArray *)retrieveAllUsersListValue;
- (NSArray *)retrieveCommonGroupListValue;
- (NSArray *)retrieveCustomGroupListValue;
- (NSArray *)retrieveSelectContactListValue;

- (NSInteger)retrieveCustomGroupIdValue;

- (NSArray *)retrieveQuickReplyListValue;
- (NSString *)retrieveQuickReplyIdValue;
- (NSInteger)retrieveMaxSizeValue;

@end
