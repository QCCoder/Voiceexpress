//
//  VEIntelligenceLabel.m
//  voiceexpress
//
//  Created by apple on 15/11/13.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VEIntelligenceLabel.h"

@implementation VEIntelligenceLabel

-(void)setText:(NSString *)text
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
    textAttachment.image = Image(Icon_Intellig_Down);
    
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
    [string insertAttributedString:textAttachmentString atIndex:string.length];
    
    [string addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.1],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, string.length)];
    self.attributedText = string;
}

@end
