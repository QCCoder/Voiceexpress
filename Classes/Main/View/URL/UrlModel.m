//
//  UrlModel.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/1.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "UrlModel.h"
#import "RegexKitLite.h"
#import "TextPart.h"
@implementation UrlModel

+(NSString *)urlContent:(NSString *)content{
    //链接规则
    NSString *urlHead = [@"(((http|ftp|https|file)://)|((?<!((http|ftp|https|file)://))www\\.))" lowercaseString];
    NSString *urlBottom = @".*?";
    NSString *urlFoot = @"(?=(&nbsp;|\\s|　|<br />|$|[<>])|[\\u4e00-\\u9fa5])";

    NSString *urlPattern = [NSString stringWithFormat:@"%@%@%@",urlHead,urlBottom,urlFoot];
    
    NSMutableArray *parts = [NSMutableArray array];
    
    [content enumerateStringsMatchedByRegex:urlPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        TextPart *part = [[TextPart alloc]init];
        part.isSpecial = YES;
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    [content enumerateStringsSeparatedByRegex:urlPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        TextPart *part = [[TextPart alloc]init];
        part.isSpecial = NO;
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    [parts sortUsingComparator:^NSComparisonResult(TextPart *part1,TextPart *part2) {
        if (part1.range.location > part2.range.location) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    NSString *str = @"";

    for (TextPart *part in parts){
        NSString *substr = @"";
        if (part.isSpecial) {
            substr = [self addScheme:part.text];
        }else{
            substr = part.text;
        }
        str = [NSString stringWithFormat:@"%@%@",str,substr];
    }
    return str;
}


+(NSString *)addScheme:(NSString *)url{
    return [NSString stringWithFormat:@"<a href=\"VoiceExpressGongan://%@\">%@</a>",url,url];
};

@end
