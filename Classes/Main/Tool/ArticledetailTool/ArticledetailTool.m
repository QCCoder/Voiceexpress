//
//  ArticledetailTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "ArticledetailTool.h"
#import <MessageUI/MessageUI.h>
#import "MessageTool.h"
#import "VEOriginalViewController.h"
#define kOptionActionSheetTag  600
#define kShareActionSheetTag   700
#define kSetFontActionSheetTag 800

@interface ArticledetailTool()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) UIViewController *vc;

@property (nonatomic,strong) UIActionSheet *actionSheet;
@property (nonatomic,strong) Agent *agent;
@end

@implementation ArticledetailTool

single_implementation(ArticledetailTool)

+(void)loadArticleContentWithRequest:(AriticledetailRequest *)request success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [HttpModelTool postWithUrl:@"articledetail" requestModel:request responseClass:[Articledetail class] success:^(id model) {
        success(model);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+(void)loadWarnFavoriteWithRequest:(AriticledetailRequest *)request Result:(ResultBlock)result
{
    NSDictionary *params = [request keyValues];
    [HttpTool postWithUrl:@"WarnFavoritesState" Parameters:params Success:^(id JSON) {
        result(JSON[@"warnFavorites"],[JSON[@"result"] integerValue],@"");
    } Failure:^(NSError *error) {
        result(@"",HTTPERROR,[error localizedDescription]);
    }];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(applicationDidEnterBackgroundNotification)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:nil];
    }
    return self;
}

-(void)showList:(UIViewController *)vc agent:(Agent *)agent{
    _vc = vc;
    _agent = agent;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"分享", @"复制", @"字体设置", nil];
    [actionSheet showInView:[[UIApplication sharedApplication].windows lastObject]];
    _actionSheet = actionSheet;
}

-(void)showWithOrgList:(UIViewController *)vc agent:(Agent *)agent{
    _vc = vc;
    _agent = agent;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"分享", @"复制",@"字体设置",@"查看原文", nil];
    [actionSheet showInView:[[UIApplication sharedApplication].windows lastObject]];
    _actionSheet = actionSheet;
}

-(void)showWithDeleteList:(UIViewController *)vc agent:(Agent *)agent{
    _vc = vc;
    _agent = agent;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"分享", @"复制",@"删除", @"字体设置", nil];
    [actionSheet showInView:[[UIApplication sharedApplication].windows lastObject]];
    _actionSheet = actionSheet;
}


#pragma mark UIActionSheet代理

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnText = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btnText isEqualToString:@"分享"]) {
        [self doShare];
    }else if([btnText isEqualToString:@"复制"]){
        [self doShareViaCopy];
    }else if([btnText isEqualToString:@"删除"]){
        [self doDelete];
    }else if ([btnText isEqualToString:@"字体设置"]){
        [self doSettingFontSize];
    }else if ([btnText isEqualToString:@"邮件"]){
        [self doShareViaMail];
    }else if ([btnText isEqualToString:@"短信"]){
        [self doShareViaMessage];
    }else if ([btnText isEqualToString:@"查看原文"]){
        [self doCheckOrg];
    }else if (actionSheet.tag == kSetFontActionSheetTag){
        NSInteger fontSize = 0;
        switch (buttonIndex)
        {
            case 0:
                fontSize = kSmallFontSize;
                break;
                
            case 1:
                fontSize = kMiddleFontSize;
                break;
                
            case 2:
                fontSize = kBigFontSize;
                break;
                
            case 3:
                fontSize = kSuperBigFontSize;
                break;
                
            default:
                break;
        }
        
        if (fontSize > 0)
        {
            [VEUtility setContentFontSize:fontSize];
            if ([self.delegate respondsToSelector:@selector(changeFontsize:)]) {
                [self.delegate changeFontsize:fontSize];
            }
        }
    }
}

/**
 *  分享
 */
- (void)doShare
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"邮件", @"短信", nil];
    actionSheet.tag = kShareActionSheetTag;
    [actionSheet showInView:[[UIApplication sharedApplication].windows lastObject]];
    _actionSheet = actionSheet;
}

/**
 *  复制
 */
- (void)doShareViaCopy
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self retrieveShareContent];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"内容拷贝成功\n您可在短信或邮件中粘贴发送"
                                                   delegate:nil
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 *  删除
 */
-(void)doDelete{
    if ([self.delegate respondsToSelector:@selector(doDelete)]) {
        [self.delegate doDelete];
    }
}

/**
 *  字体设置
 */
- (void)doSettingFontSize
{
    NSInteger curFontSize = [VEUtility contentFontSize];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"字体设置"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  (curFontSize == kSmallFontSize ? @"    小  √" : @"小"),
                                  (curFontSize == kMiddleFontSize ? @"    中  √" : @"中"),
                                  (curFontSize == kBigFontSize ? @"    大  √" : @"大"),
                                  (curFontSize == kSuperBigFontSize ? @"    特大  √" : @"特大"), nil];
    actionSheet.tag = kSetFontActionSheetTag;
    [actionSheet showInView:_vc.view];
    _actionSheet = actionSheet;
}

-(void)doCheckOrg{
    VEOriginalViewController *VC = [[VEOriginalViewController alloc]init];
    VC.originalUrl = [_agent performSelector:@selector(url)];
    [_vc.navigationController pushViewController:VC animated:YES];
}

// 分享的内容: 标题、作者、时间、内容、原文链接
- (NSString *)retrieveShareContent
{
    NSString *shareContent = @"";
    // 标题
    if (_agent.title.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"标题：%@\n", _agent.title];
    }
    NSString *stringUrl = nil;
    Agent *agent = _agent;
    
    // 作者
    if ([agent respondsToSelector:@selector(author)])
    {
        NSString *author = [agent performSelector:@selector(author)];
        if (author.length > 0)
        {
            shareContent = [shareContent stringByAppendingFormat:@"作者：%@\n", author];
        }
    }
    
    // 来源
    if ([agent respondsToSelector:@selector(site)])
    {
        NSString *site = [agent performSelector:@selector(site)];
        if (site.length > 0)
        {
            shareContent = [shareContent stringByAppendingFormat:@"来源：%@\n", site];
        }
    }
    
    // 发文时间
    if (agent.timePost.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"发文时间：%@\n", agent.timePost];
    }
    
    // 原文链接
    if ([agent respondsToSelector:@selector(url)])
    {
        stringUrl = [agent performSelector:@selector(url)];
    }
    // 原文链接
    if (stringUrl.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"原文链接：%@", stringUrl];
    }
    
    // 内容
    if (agent.articleContent.length > 0)
    {
        
        // Scanner
        NSScanner *scanner = [[NSScanner alloc] initWithString:agent.articleContent];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet*newLineAndWhitespaceCharacters = [ NSCharacterSet newlineCharacterSet];
        // Scan
        while (![scanner isAtEnd]) {
            
            // Get non new line or whitespace characters
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            
            // Replace with a space
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                    [result appendString:@" "];
            }
        }
        
        // Return
        NSString *retString = [NSString stringWithString:result];
        
        shareContent = [shareContent stringByAppendingFormat:@"内容：%@", retString];
        shareContent = [shareContent substringToIndex:[shareContent length] - 1];
        shareContent = [shareContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return shareContent;
}

/**
 *  邮件
 */
- (void)doShareViaMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        [mailViewController setToRecipients:nil];
        [mailViewController setMessageBody:[[ArticledetailTool sharedArticledetailTool] retrieveShareContent] isHTML:NO];
        [_vc presentViewController:mailViewController animated:YES completion:NULL];
    }
    else
    {
        DLog(@"当前设备不支持发送邮件");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"当前设备不支持发送邮件"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

/**
 *  短信
 */
- (void)doShareViaMessage
{
    if ([MFMessageComposeViewController canSendText])
    {
    
        
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.messageComposeDelegate = self;
        [messageVC setBody:[self retrieveShareContent]];
        
        [_vc presentViewController:messageVC animated:YES completion:NULL];
    }
    else
    {
        DLog(@"当前设备不支持发送短信");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"当前设备不支持发送短信"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [_vc dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"邮件已发出"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [_vc dismissViewControllerAnimated:YES completion:NULL];
}

- (void)applicationDidEnterBackgroundNotification
{
    [self.actionSheet dismissWithClickedButtonIndex:(self.actionSheet.numberOfButtons - 1)
                                           animated:NO];
}


// 分享的内容: 标题、作者、时间、内容、原文链接
+ (IntelligenceAgent *)getForward:(Agent *)agent
{
    NSString *shareContent = @"\n-------------原文-------------\n";;
    NSString *stringUrl = nil;
    
    // 作者
    if ([agent respondsToSelector:@selector(author)])
    {
        NSString *author = [agent performSelector:@selector(author)];
        if (author.length > 0)
        {
            shareContent = [shareContent stringByAppendingFormat:@"作者：%@\n", author];
        }
    }
    
    // 来源
    if ([agent respondsToSelector:@selector(site)])
    {
        NSString *site = [agent performSelector:@selector(site)];
        if (site.length > 0)
        {
            shareContent = [shareContent stringByAppendingFormat:@"来源：%@\n", site];
        }
    }
    
    // 发文时间
    if (agent.timePost.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"发文时间：%@\n", agent.timePost];
    }
    
    // 原文链接
    if ([agent respondsToSelector:@selector(url)])
    {
        stringUrl = [agent performSelector:@selector(url)];
    }
    // 原文链接
    if (stringUrl.length > 0)
    {
        shareContent = [shareContent stringByAppendingFormat:@"原文链接：%@\n", stringUrl];
    }
    
    // 内容
    if (agent.articleContent.length > 0)
    {
        
        // Scanner
        NSScanner *scanner = [[NSScanner alloc] initWithString:agent.articleContent];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet*newLineAndWhitespaceCharacters = [ NSCharacterSet newlineCharacterSet];
        // Scan
        while (![scanner isAtEnd]) {
            
            // Get non new line or whitespace characters
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            
            // Replace with a space
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                    [result appendString:@" "];
            }
        }
        
        // Return
        NSString *retString = [NSString stringWithString:result];
        
        shareContent = [shareContent stringByAppendingFormat:@"内容：%@", retString];
        shareContent = [shareContent substringToIndex:[shareContent length] - 1];
        shareContent = [shareContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    IntelligenceAgent *msgAgent = [[IntelligenceAgent alloc]init];
    msgAgent.articleContent = shareContent;
    msgAgent.title = agent.title;
    msgAgent.warnLevel = agent.warnLevel;
    msgAgent.warnType = agent.warnType;
    return msgAgent;
}



@end
