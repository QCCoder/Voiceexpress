//
//  VEJsonParser.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-27.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

static NSString * const kJsonResult                     = @"result";
static NSString * const kJsonUGroupID                   = @"uGroupID";
static NSString * const kJsonSessionToken               = @"sessionToken";
static NSString * const kJsonDefaultPwd                 = @"defaultpwd";
static NSString * const kJsonSecCtrlOpen                = @"SecurityCtrlOpen";
static NSString * const kJsonLockCtrlOpen               = @"LockCtrlOpen";
static NSString * const kJsonIntelligenceNeedWhole      = @"isIntelligenceNeedWhole";
static NSString * const kJsonNetworkReportReview        = @"NetworkReportReview";

static NSString * const kJsonErrorMessage   = @"message";
static NSString * const kJsonSize           = @"size";
static NSString * const kJsonList           = @"list";
static NSString * const kJsonCount          = @"count";
static NSString * const kJsonLid            = @"lid";
static NSString * const kJsonUid            = @"uid";
static NSString * const kJsonGid            = @"suid";
static NSString * const kJsonFavorateState  = @"warnFavorites";
static NSString * const kJsonContent        = @"content";
static NSString * const kJsonProposals      = @"proposals";
static NSString * const kJsonProposalsId    = @"suggestId";

static NSString * const kJsonImageUrls      = @"imageUrls";
static NSString * const kJsonImageUrl       = @"imageUrl";
static NSString * const kJsonAutoPush       = @"isPush";
static NSString * const kJsonNightNoDisturb = @"isNightNodisturb";
static NSString * const kJsonPushLevels     = @"veLevels";
static NSString * const kJsonImages         = @"images";
static NSString * const kJsonNewInBoxSize   = @"receivedWarnSize";
static NSString * const kJsonNewOutBoxSize  = @"sendedWarnSize";
static NSString * const kJsonReceiverNames  = @"username";
static NSString * const kJsonReceiverReadState  = @"readStatus";
static NSString * const kJsonMaxSize            = @"maxsize";

static NSString * const kJsonToMeReplylist          = @"toMe";
static NSString * const kJsonRelativeMeReplylist    = @"aboutMe";

static NSString * const kJsonMandatoryUpdate   = @"mandatory";
static NSString * const kJsonUpdateDiscription = @"discription";

static NSString * const kJsonInternetArea  = @"dict_area";
static NSString * const kJsonInternetType  = @"dict_info";
static NSString * const kJsonInternetDept  = @"dept_info";

static NSString * const kJsonLocalTags    = @"localtags";

static NSString * const kJsonAllUsersList       = @"allUsersList";
static NSString * const kJsonCommonGroupList    = @"commonContactsList";
static NSString * const kJsonCustomGroupList    = @"customGroupList";
static NSString * const kJsonSelectContactList  = @"selectContactList";

static NSString * const kJsonCustomGroupId      = @"customGroupId";
static NSString * const kJsonQuickReplyList     = @"quickReplyList";
static NSString * const kJsonQuickReplyId       = @"quickReplyId";

#import "VEJsonParser.h"

@interface VEJsonParser ()
@property (nonatomic, strong) NSDictionary *jsonDicValue;
@end

@implementation VEJsonParser

@synthesize jsonDicValue;

- (id)initWithJsonDictionary:(NSDictionary *)aJsonDicValue
{
    self.jsonDicValue = aJsonDicValue;
    return self;
}

- (NSInteger)retrieveNewInBoxSizeValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objResult = [self.jsonDicValue objectForKey:kJsonNewInBoxSize];
        if (objResult != nil)
        {
            return [objResult integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveNewOutBoxSizeValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objResult = [self.jsonDicValue objectForKey:kJsonNewOutBoxSize];
        if (objResult != nil)
        {
            return [objResult integerValue];
        }
    }
    return 0;
}


- (NSInteger)retrieveRusultValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objResult = [self.jsonDicValue objectForKey:kJsonResult];
        if (objResult != nil)
        {
            return [objResult integerValue];
        }
    }
    return NSIntegerMin;
}

- (BOOL)retrieveMandatoryUpdateValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonMandatoryUpdate] boolValue];
    }
    return NO;
}

- (NSString *)retrieveUpdateDiscriptionValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id updateDiscription = [self.jsonDicValue objectForKey:kJsonUpdateDiscription];
        if (updateDiscription != nil)
        {
            return updateDiscription;
        }
    }
    return @"";
}

- (NSInteger)retrieveUGroupIDValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objResult = [self.jsonDicValue objectForKey:kJsonUGroupID];
        if (objResult != nil)
        {
            return [objResult integerValue];
        }
    }
    return NSIntegerMin;
}

- (NSString *)retrieveSessionTokenValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSessionToken = [self.jsonDicValue objectForKey:kJsonSessionToken];
        if (objSessionToken != nil)
        {
            return objSessionToken;
        }
    }
    return @"0";
}

- (BOOL)retrieveIsDefaultPasswordValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonDefaultPwd] boolValue];
    }
    return NO;
    
}

- (BOOL)retrieveIsSecurityCtrlOpenValue;
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonSecCtrlOpen] boolValue];
    }
    return NO;
}

- (BOOL)retrieveIsLockCtrlOpenValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonLockCtrlOpen] boolValue];
    }
    return NO;
}

- (BOOL)retrieveIsIntelligenceNeedWholeValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonIntelligenceNeedWhole] boolValue];
    }
    return NO;
}

- (BOOL)retrieveNetworkReportReviewValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonNetworkReportReview] boolValue];
    }
    return NO;
}

- (NSInteger)retrieveSizeValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonSize];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveMaxSizeValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonMaxSize];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveCustomGroupIdValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonCustomGroupId];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveCountValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonCount];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveLIDValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonLid];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveUIDValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonUid];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSInteger)retrieveGIDValue
{
    if ([self.jsonDicValue count] > 0)
    {
        id objSize = [self.jsonDicValue objectForKey:kJsonGid];
        if (objSize != nil)
        {
            return [objSize integerValue];
        }
    }
    return 0;
}

- (NSArray *)retrieveListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonList];
    }
    return nil;
}

- (NSArray *)retrieveImagesValues
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonImages];
    }
    return nil;
}

- (NSArray *)retrieveToMeReplyListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonToMeReplylist];
    }
    return nil;
}

- (NSArray *)retrieveRelativeMeReplyListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonRelativeMeReplylist];
    }
    return nil;
}

- (NSArray *)retrieveInternetAreaListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonInternetArea];
    }
    return nil;
}

- (NSArray *)retrieveInternetTypeListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonInternetType];
    }
    return nil;
}

- (NSArray *)retrieveInternetOrganizeListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonInternetDept];
    }
    return nil;
}

- (NSArray *)retrievelocalTagsValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonLocalTags];
    }
    return nil;
}

- (NSArray *)retrieveAllUsersListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonAllUsersList] objectForKey:kJsonList];
    }
    return nil;
}

- (NSArray *)retrieveCommonGroupListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonCommonGroupList] objectForKey:kJsonList];
    }
    return nil;
}

- (NSArray *)retrieveCustomGroupListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonCustomGroupList] objectForKey:kJsonList];
    }
    return nil;
}

- (NSArray *)retrieveSelectContactListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonSelectContactList] objectForKey:kJsonList];
    }
    return nil;
}

- (NSArray *)retrieveQuickReplyListValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonQuickReplyList];
    }
    return nil;
}

- (NSString *)retrieveQuickReplyIdValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonQuickReplyId] stringValue];
    }
    return nil;
}

- (BOOL)retrieveFavoriteStateValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonFavorateState] boolValue];
    }
    return NO;
}

- (NSString *)retrieveContentValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonContent];
    }
    return nil;
}

- (NSString *)retrieveProposalsValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonProposals];
    }
    return nil;
}

- (NSString *)retrieveProposalsValueId
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonProposalsId];
    }
    return nil;
}



- (NSArray *)retrieveImageUrlsValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[[self.jsonDicValue valueForKey:kJsonImageUrls] valueForKey:kJsonImageUrl] copy];
    }
    return nil;
}

- (NSString *)retrieveServerErrorMessageValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonErrorMessage];
    }
    return nil;
}

- (NSString *)retrieveReceiverNames
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonReceiverNames];
    }
    return nil;
}

- (NSString *)retrieveReceiverReadState
{
    if ([self.jsonDicValue count] > 0)
    {
        return [self.jsonDicValue objectForKey:kJsonReceiverReadState];
    }
    return nil;
}

- (BOOL)retrieveAutoPushValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonAutoPush] boolValue];
    }
    return NO;
}

- (BOOL)retrieveNightNoDisturbValue
{
    if ([self.jsonDicValue count] > 0)
    {
        return [[self.jsonDicValue objectForKey:kJsonNightNoDisturb] boolValue];
    }
    return NO;
}

- (BOOL)retrievePushGenralAlertValue
{
    if ([self.jsonDicValue count] > 0)
    {
        NSString *pushlevels = [self.jsonDicValue objectForKey:kJsonPushLevels];
        if ([pushlevels length] > 0)
        {
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"{" withString:@","];
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"}" withString:@","];
            
            NSRange range = [pushlevels rangeOfString:@",3,"];
            if (range.location != NSNotFound)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)retrievePushSeriousAlertValue
{
    if ([self.jsonDicValue count] > 0)
    {
        NSString *pushlevels = [self.jsonDicValue objectForKey:kJsonPushLevels];
        if ([pushlevels length] > 0)
        {
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"{" withString:@","];
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"}" withString:@","];
            
            NSRange range = [pushlevels rangeOfString:@",2,"];
            if (range.location != NSNotFound)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)retrievePushUrgentAlertValue
{
    if ([self.jsonDicValue count] > 0)
    {
        NSString *pushlevels = [self.jsonDicValue objectForKey:kJsonPushLevels];
        if ([pushlevels length] > 0)
        {
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"{" withString:@","];
            pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"}" withString:@","];
            
            NSRange range = [pushlevels rangeOfString:@",1,"];
            if (range.location != NSNotFound)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void)reportErrorMessage
{
    NSString *alertMessage = nil;
    NSInteger resultValue = [self retrieveRusultValue];

    switch (resultValue)
    {
        case 1:
            alertMessage = @"用户名或密码不正确";
            break;
            
        case 2:
            alertMessage = @"用户名或密码为空";
            break;
            
        case 3:
            alertMessage = @"用户已过期失效";
            break;
            
        case 4:
            alertMessage = @"非法客户端";
            break;
            
        case 5:
            alertMessage = @"您的账号在另一地方被登录了,\r\n请重新登录";
            break;
            
        case 6:
            alertMessage = @"参数错误";
            break;
            
        case 7:
            alertMessage = @"软件版本太低，需升级到最新版本";
            break;
            
        case 9:
            alertMessage = @"服务器错误";
            break;
            
        case -3:
            alertMessage = @"操作失败";
            break;
            
        case -4:
            alertMessage = @"收藏状态初始化失败";
            break;
            
        case NSIntegerMin:
            alertMessage = @"服务器返回数据格式错误";
            break;
            
        default:
            alertMessage = [NSString stringWithFormat:@"未定义的错误码: %ld", (long)resultValue];
            break;
            
    }
    
    id objErrorMsg = [self.jsonDicValue objectForKey:kJsonErrorMessage];
    if (objErrorMsg != nil)
    {
        alertMessage = [alertMessage stringByAppendingFormat:@"\r\n%@", objErrorMsg];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:alertMessage
                                                  delegate:nil
                                         cancelButtonTitle:@"好的"
                                         otherButtonTitles:nil];
    DLog(@"reportErrorMessage: %@", alertMessage);
    if (5 != resultValue)
    {
        [alertView show];
    }
  
    if (5 == resultValue)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [VEUtility returnToLoginInterface:YES];
        }];
    }
}

- (void)printOutServerErrorMessage
{
    DLog(@"Server error code: %ld, discription: %@", (long)[self retrieveRusultValue], [self retrieveServerErrorMessageValue]);
}

@end
