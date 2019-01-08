//
// Agent.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-8-22.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//
#import "UIColor+Utils.h"
#import "Agent.h"


/////////////////////////////////////////////////////////////////////////////////////

@implementation Agent

MJCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{@"articleId":@"aid",
                           @"timePost":@"tmPost",
                           };
    
    return dict;
}

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        self.articleId  = [[item valueForKey:kArticleId] stringValue];
        self.title      = [item valueForKey:kTitle];
        self.timePost   = [item valueForKey:kTimePost];
        self.warnLevel  = [[item valueForKey:kWarnLevel] integerValue];
        self.warnType   = [[item valueForKey:kWarnType] integerValue];
        self.isRead     = NO;
    }
    return self;
}
@end


/////////////////////////////////////////////////////////

//@implementation RecommendColumnAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super init];
//    if (self)
//    {
//        self.columnId           = [[item valueForKey:kColumnId] stringValue];
//        self.columnTitle        = [item valueForKey:kColumnTitle];
//        self.newestArticleId    = [[item valueForKey:kColumnNewestArticleId] integerValue];
//        self.iconURL            = [item valueForKey:kColumnIconURL];
//        self.localNewestArticleId = 0;
//    }
//    return self;
//}
//
//@end


//@implementation RecommendAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super initWithDictionary:item];
//    if (self)
//    {
//        self.thumbImageUrl = [item valueForKey:kThumbImageUrl];
//        self.imageUrls = [[[item valueForKey:kImageUrls] valueForKey:kImageUrl] copy];
//    }
//    return self;
//}
//
//@end


/////////////////////////////////////////////////////////

//@implementation FavoriteAlertAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super initWithDictionary:item];
//    if (self)
//    {
//        self.timeFavorited = [[item valueForKey:kTimeFavorited] stringValue];
//    }
//    return self;
//}
//
//@end


//@implementation FavoriteRecommendAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super initWithDictionary:item];
//    if (self)
//    {
//        self.timeFavorited = [[item valueForKey:kTimeFavorited] stringValue];
//    }
//    return self;
//}
//
//@end


/////////////////////////////////////////////////////////

//@implementation IntelligenceColumnAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super init];
//    if (self)
//    {
//        double aboutMeNewestTm  = [[item valueForKey:kAboutMeNewestTm] doubleValue];
//        double receivedNewestTm = [[item valueForKey:kReceivedNewestTm] doubleValue];
//        double sendedNewestTm   = [[item valueForKey:kSendedNewestTm] doubleValue];
//        self.newestTime = MAX((MAX(aboutMeNewestTm, receivedNewestTm)), sendedNewestTm);
//        self.loacalNewestTime = 0;
//        
//        NSInteger type = [[item valueForKey:kExchangeType] integerValue];
//        switch (type)
//        {
//            case 1:
//                self.columnType = IntelligenceColumnInstant;
//                break;
//                
//            case 2:
//                self.columnType = IntelligenceColumnDaily;
//                break;
//                
//            case 3:
//                self.columnType = IntelligenceColumnInternational;
//                break;
//                
//            case 4:
//                self.columnType = IntelligenceColumnAllIntelligence;
//                break;
//
//            default:
//                self.columnType = IntelligenceColumnNone;
//                break;
//        }
//    }
//    return self;
//}
//
//@end


//@implementation IntelligenceAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super initWithDictionary:item];
//    if (self)
//    {
//        // 解密
//        NSString *encryptedStr = self.title;
//        self.title = [DES3Util decrypt:encryptedStr];
//        self.showTitle = [item valueForKey:kShowTitle];
//        self.numberTitle = [item valueForKey:kNumberTitle];
//        self.author = [item valueForKey:kAuthor];
//    
//        NSString *names = [item valueForKey:kReceiverNames];
//        
//        if(![names isKindOfClass:[NSNull class]]){
//            if (names.length > 0)
//            {
//                names = [names stringByReplacingOccurrencesOfString:@"{" withString:@""];
//                names = [names stringByReplacingOccurrencesOfString:@"}" withString:@""];
//                
//                self.receiverNames = [[names componentsSeparatedByString:@","] copy];
//            }
//        }
//        
////        self.thumbImageUrl    = [item valueForKey:kThumbImageUrl];
////        self.imageUrls        = [[[item valueForKey:kImageUrls] valueForKey:kImageUrl] copy];
//        self.latestTimeReply  = [[item valueForKey:kTimeWarn] doubleValue];
//        double temp1          = [[item valueForKey:kNewestTimeReply] doubleValue];
//        self.newsTimeReply = temp1;
//        self.newestTimeReply  = MAX(temp1, self.latestTimeReply);
//        self.isReadMarkUpload = NO;
//        if ([[item valueForKey:@"levelColor"] isEqualToString:@""]) {
//            self.levelCode = @"";
//            self.levelName = @"无";
//            self.levelTip = @"";
//            self.levelColor = nil;
//        }else{
//
//            self.levelCode = [[item valueForKey:@"levelCode"] copy];
//            self.levelName = [[item valueForKey:@"levelName"] copy];
//            self.levelTip = [[item valueForKey:@"levelTip"] copy];
//            self.levelColor = [UIColor colorWithHexString:[[item valueForKey:@"levelColor"] copy]];
////            DLog(@"levelColor is %@",[item valueForKey:@"levelColor"]);
//        }
//    }
//    return self;
//}
//
//@end
/////////////////////////////////////////////////////////
#warning unImplementation
@implementation WarnningTypeAgent
-(instancetype)initWithDictionary:(NSDictionary *)item{
    self = [super init];
    if(self){
        if ([[[item valueForKey:@"levelCode"] copy] isEqualToString:@""]) {
            self.levelCode = @"";
            self.levelName = @"无";
            self.levelTip = @"";
            self.levelColor = nil;
           
        }else{
            self.levelCode = [[item valueForKey:@"levelCode"] copy];
            self.levelName = [[item valueForKey:@"levelName"] copy];
            self.levelTip = [[item valueForKey:@"levelTip"] copy];
            self.levelColor = [UIColor colorWithHexString:[[item valueForKey:@"levelColor"] copy]];
        }
    }
    return self;
}



@end
/////////////////////////////////////////////////////////

//@implementation ReplyAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super init];
//    if (self)
//    {
//        NSString *encryptedStr = [item valueForKey:kContent];
//        self.content   = [DES3Util decrypt:encryptedStr];
//        self.fromName  = [item valueForKey:kFromName];
//        self.replyTime = [item valueForKey:kReplyTime];
//        self.showTip   = [item valueForKey:kShowTip];
//    }
//    return self;
//}
//
//@end


//@implementation ReplyGroupAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super init];
//    if (self)
//    {
//        self.replyUserId   = [[item valueForKey:kReplyUserId] stringValue];
//        self.replyUserName = [item valueForKey:kReplyUserName];
//        
//        NSMutableArray *groupList = [NSMutableArray array];
//        for (NSDictionary *replyItem in [item valueForKey:kReplygroupList])
//        {
//            ReplyAgent *replyAgent = [[ReplyAgent alloc] initWithDictionary:replyItem];
//            [groupList addObject:replyAgent];
//        }
//        self.replyGroupList = groupList;
//    }
//    return self;
//}
//
//@end



/////////////////////////////////////////////////////////

@implementation ContactGroupAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        self.groupId   = [[item valueForKey:kContactGroupId] integerValue];
        self.groupName = [item valueForKey:kContactGroupName];
        
        NSMutableArray *members = [NSMutableArray array];
        for (NSDictionary *contactDic in [item valueForKey:kContactGroupMember])
        {
            ContactAgent *contactAgent = [[ContactAgent alloc] initWithDictionary:contactDic];
            [members addObject:contactAgent];
        }
        self.groupMember = members;
    }
    return self;
}

@end


@implementation ContactAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        self.userId          = [[item valueForKey:kContactUserId] integerValue];
        self.userName        = [item valueForKey:kContactUserName];
        self.isFavorited     = [[item valueForKey:kContactUserIsFavrorited] boolValue];
        self.userNamePY      = [item valueForKey:kContactFullNamePinYin];
        self.allFirstLetters = [item valueForKey:kContactFirstLetterPinYin];
    }
    return self;
}

@end



/////////////////////////////////////////////////////////

@implementation InternetAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self)
    {
        NSString *encryptedAuthor = [item valueForKey:kAuthor];
        self.author       = [DES3Util decrypt:encryptedAuthor];
        NSString *str =[DES3Util decrypt:self.title];
        self.title        = str;
        self.timeWarn     = [item valueForKey:kTimeWarn];
        self.internetArea = [item valueForKey:kInternetArea];
        self.internetType = [item valueForKey:kInternetType];
        self.uuid = [item valueForKey:kUuid];
        
        NSString *encryptedDept = [item valueForKey:kInternetDept];
        self.internetDept = [DES3Util decrypt:encryptedDept];
    }
    return self;
}

@end



/////////////////////////////////////////////////////////
//
//@implementation LocalAreaAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super init];
//    if (self)
//    {
//        self.tagID      = [[item valueForKey:kTagID] stringValue];
//        self.tagName    = [item valueForKey:kTagName];
//    }
//    return self;
//}
//
//@end


/////////////////////////////////////////////////////////

@implementation QuickReplyAgent

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self)
    {
        self.quickReplyId      = [[item valueForKey:kQuickReplyID] stringValue];
        self.quickReplyMessage = [item valueForKey:kQuickReplyMessage];
    }
    return self;
}

@end


/////////////////////////////////////////////////////////

//@implementation NetworkReportingAgent
//
//- (id)initWithDictionary:(NSDictionary *)item
//{
//    self = [super initWithDictionary:item];
//    if (self)
//    {
//        self.author    = [DES3Util decrypt:[item valueForKey:kAuthor]];
//        self.title     = [DES3Util decrypt:self.title];
//        self.timeWarn  = [[item valueForKey:kTimeWarn] stringValue];
//        self.status    = [[item valueForKey:kStatus] integerValue];
//        self.area      = [item valueForKey:kArea];
//        self.nickName  = [DES3Util decrypt:[item valueForKey:kNickName]];
//        self.siteName  = [DES3Util decrypt:[item valueForKey:kSiteName]];
//        self.orgTime   = [item valueForKey:kOrgTime];
//        self.isChanged = NO;
//    }
//    return self;
//}

//@end


