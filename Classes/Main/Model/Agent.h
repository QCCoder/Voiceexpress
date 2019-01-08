//
//  Agent.h
//  voiceexpress
//
//  Created by Yaning Fan on 14-8-22.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString * const kArticleId      = @"aid";
static NSString * const kAuthor         = @"author";
static NSString * const kTitle          = @"title";
static NSString * const kShowTitle      = @"showTitle";
static NSString * const kNumberTitle    = @"numberTitle";
static NSString * const kTimePost       = @"tmPost";
static NSString * const kTimeWarn       = @"tmWarn";
static NSString * const kWebURL         = @"url";
static NSString * const kWarnLevel      = @"level";
static NSString * const kWarnType       = @"warnType";
static NSString * const kSite           = @"site";
static NSString * const kLocalTag       = @"localTag";
static NSString * const kThumbImageUrl  = @"thumbImageUrl";
static NSString * const kImageUrls      = @"imageUrls";
static NSString * const kImageUrl       = @"imageUrl";

static NSString * const kColumnId               = @"id";
static NSString * const kColumnTitle            = @"title";
static NSString * const kColumnNewestArticleId  = @"newestSectionArticleId";
static NSString * const kColumnIconURL          = @"iconFile";

static NSString * const kTimeFavorited  = @"tmFavorites";

static NSString * const kNewestTm          = @"newestTm";
static NSString * const kAboutMeNewestTm   = @"aboutMeNewestTm";   // 与我相关栏
static NSString * const kReceivedNewestTm  = @"receivedNewestTm";  // 收件箱
static NSString * const kSendedNewestTm    = @"sendedNewestTm";    // 发件箱
static NSString * const kExchangeType      = @"exchangeType";      // 情报类型

static NSString * const kNewestTimeReply   = @"newestTmReply";
static NSString * const kReceiverNames     = @"uidnames";

static NSString * const kContent           = @"content";
static NSString * const kFromName          = @"fromName";
static NSString * const kReplyTime         = @"replyTime";
static NSString * const kShowTip           = @"show";

static NSString * const kReplyUserId       = @"replyUserId";
static NSString * const kReplyUserName     = @"replyUserName";
static NSString * const kReplygroupList    = @"replygroup";

static NSString * const kContactGroupId                 = @"groupId";
static NSString * const kContactGroupName               = @"groupName";
static NSString * const kContactGroupMember             = @"groupMember";
static NSString * const kContactUserName                = @"name";
static NSString * const kContactUserId                  = @"uid";
static NSString * const kContactUserIsFavrorited        = @"isContact";
static NSString * const kContactFirstLetterPinYin       = @"firstLetterPinYin";
static NSString * const kContactFullNamePinYin          = @"fullNamePinYin";


static NSString * const kInternetArea      = @"area";
static NSString * const kInternetType      = @"type";
static NSString * const kInternetDept      = @"inputDept";
static NSString * const kUuid              = @"uuid";
static NSString * const kTagID             = @"id";
static NSString * const kTagName           = @"name";

static NSString * const kQuickReplyID      = @"quickReplyId";
static NSString * const kQuickReplyMessage = @"message";

static NSString * const kStatus   = @"status";
static NSString * const kArea     = @"area";
static NSString * const kNickName = @"nickName";
static NSString * const kSiteName = @"siteName";
static NSString * const kOrgTime  = @"orgTime";

/////////////////////////////////////////////////////////

@interface Agent : NSObject

@property (nonatomic, copy)   NSString  *articleId;
@property (nonatomic, copy)   NSString  *articleContent;
@property (nonatomic, copy)   NSString  *title;
@property (nonatomic, copy)   NSString  *timePost;
@property (nonatomic, assign) NSInteger warnLevel;
@property (nonatomic, assign) NSInteger warnType;
@property (nonatomic, assign) BOOL      isRead;

- (id)initWithDictionary:(NSDictionary *)item;

@end


/////////////////////////////////////////////////////////

//@interface RecommendColumnAgent : NSObject
//
//@property (nonatomic, copy)   NSString  *columnId;
//@property (nonatomic, copy)   NSString  *columnTitle;
//@property (nonatomic, copy)   NSString  *iconURL;
//@property (nonatomic, assign) NSInteger newestArticleId;
//@property (nonatomic, assign) NSInteger localNewestArticleId;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


//@interface RecommendAgent : Agent
//
//@property (nonatomic, strong) NSArray  *imageUrls;
//@property (nonatomic, copy)   NSString *thumbImageUrl;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


/////////////////////////////////////////////////////////

//@interface FavoriteAlertAgent : WarnAgent
//
//@property (nonatomic, copy) NSString *timeFavorited;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end



/////////////////////////////////////////////////////////

//@interface IntelligenceColumnAgent : NSObject
//
//@property (nonatomic, assign) double newestTime;
//@property (nonatomic, assign) double loacalNewestTime;
//@property (nonatomic, assign) IntelligenceColumnType columnType;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


//#warning intelligenceAgent new
//@interface IntelligenceAgent : Agent
//
//@property (nonatomic, copy)   NSString *author;
////@property (nonatomic, strong) NSArray *imageUrls;
////@property (nonatomic, copy)   NSString *thumbImageUrl;
//@property (nonatomic, strong) NSArray *receiverNames;
//@property (nonatomic, assign) double newestTimeReply;
//@property (nonatomic, assign) double latestTimeReply;
//@property (nonatomic, assign) double localTimeReply;
//@property (nonatomic, assign) double newsTimeReply;
//@property (nonatomic, assign) BOOL   isReadMarkUpload;
//
//@property (nonatomic,copy ) NSString * levelName;
//@property (nonatomic,copy ) NSString * levelCode;
//@property (nonatomic,copy ) NSString * levelTip;
//@property (nonatomic,copy) NSString *numberTitle;
//@property (nonatomic,copy) NSString *showTitle;
//@property (nonatomic,strong) UIColor  * levelColor;
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


/////////////////////////////////////////////////////////

@interface WarnningTypeAgent : NSObject

@property(nonatomic,copy ) NSString * levelName;
@property(nonatomic,copy ) NSString * levelCode;
@property(nonatomic,copy ) NSString * levelTip;
@property(nonatomic,strong ) UIColor  * levelColor;
-(instancetype)initWithDictionary:(NSDictionary*)item;

@end
/////////////////////////////////////////////////////////

//@interface ReplyAgent : NSObject
//
//@property (nonatomic, copy)   NSString *content;
//@property (nonatomic, copy)   NSString *fromName;
//@property (nonatomic, copy)   NSString *replyTime;
//@property (nonatomic, copy)   NSString *showTip;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


//@interface ReplyGroupAgent : NSObject
//
//@property (nonatomic, copy)   NSString *replyUserId;
//@property (nonatomic, copy)   NSString *replyUserName;
//@property (nonatomic, strong) NSArray *replyGroupList;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end



/////////////////////////////////////////////////////////

@interface ContactGroupAgent : NSObject

@property (nonatomic, assign) NSInteger         groupId;
@property (nonatomic, copy)   NSString          *groupName;
@property (nonatomic, strong) NSMutableArray    *groupMember;

- (id)initWithDictionary:(NSDictionary *)item;

@end


@interface ContactAgent : NSObject

@property (nonatomic, copy)   NSString    *userName;
@property (nonatomic, copy)   NSString    *userNamePY;
@property (nonatomic, copy)   NSString    *allFirstLetters;
@property (nonatomic, assign) NSInteger   userId;
@property (nonatomic, assign) BOOL        isFavorited;

- (id)initWithDictionary:(NSDictionary *)item;

@end



/////////////////////////////////////////////////////////

@interface InternetAgent : Agent

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *timeWarn;
@property (nonatomic, copy) NSString *internetArea;
@property (nonatomic, copy) NSString *internetDept;
@property (nonatomic, copy) NSString *internetType;
@property (nonatomic,copy) NSString *uuid;
- (id)initWithDictionary:(NSDictionary *)item;

@end


///////////////////////////////////////////////////////////
//
//@interface LocalAreaAgent : NSObject
//
//@property (nonatomic, copy) NSString *tagID;
//@property (nonatomic, copy) NSString *tagName;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end


/////////////////////////////////////////////////////////

@interface QuickReplyAgent : NSObject

@property (nonatomic, copy) NSString *quickReplyId;
@property (nonatomic, copy) NSString *quickReplyMessage;

- (id)initWithDictionary:(NSDictionary *)item;

@end


///////////////////////////////////////////////////////////
//
//@interface NetworkReportingAgent : Agent
//
//@property (nonatomic, copy) NSString *author;
//@property (nonatomic, copy) NSString *timeWarn;
//@property (nonatomic, assign) NSInteger status;
//@property (nonatomic, assign) BOOL isChanged;
//@property (nonatomic, copy) NSString *area;
//@property (nonatomic, copy) NSString *nickName;
//@property (nonatomic, copy) NSString *siteName;
//@property (nonatomic, copy) NSString *orgTime;
//
//- (id)initWithDictionary:(NSDictionary *)item;
//
//@end




