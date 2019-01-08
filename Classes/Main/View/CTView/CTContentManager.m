//
//  CTContentManager.m
//  Demo
//
//  Created by Yaning Fan on 14-9-10.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "CTContentManager.h"
#import "CTView.h"
#import <CoreText/CoreText.h>

static const NSInteger kNumsofCharactersPerCell = 1000;

@interface CTContentManager ()

@property (nonatomic, strong) NSMutableArray *heightList;

@end

@implementation CTContentManager

- (void)refreshCellHeigtList
{
    if (self.heightList == nil)
    {
        self.heightList = [NSMutableArray array];
    }
    [self.heightList removeAllObjects];
    
    NSInteger allRows = ceil((double)self.content.length / kNumsofCharactersPerCell);
    for (int i = 0; i < allRows; ++i)
    {
        CGFloat temp = [self retrieveRowHightAtIndex:i];
        [self.heightList addObject:[NSNumber numberWithFloat:temp]];
    }
}

- (CGFloat)retrieveRowHightAtIndex:(NSInteger)index
{
    return [self parseHightAtString:[self retrieveContentAtIndex:index]];
}

- (CGFloat)parseHightAtString:(NSString *)aString
{
    if (aString.length == 0)
    {
        return 0;
    }
    
    @autoreleasepool {
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
        lineSpaceStyle.valueSize = sizeof(_lineSpace);
        lineSpaceStyle.value = &_lineSpace;
        
        CTParagraphStyleSetting settings[] = { lineSpaceStyle };
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(CTParagraphStyleSetting));
        
        // CFSTR("Helvetica-Bold")
        CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), self.fontSize, NULL);
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge id)font, kCTFontAttributeName,
                               (__bridge id)style, kCTParagraphStyleAttributeName, nil];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:aString
                                                                                       attributes:attrs];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrString));
        CFRange fitRange;
        CGSize sugframeSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                           CFRangeMake(0, attrString.length),
                                                                           NULL,
                                                                           CGSizeMake((self.viewWidth - 2 * self.xOffSet), CGFLOAT_MAX),
                                                                           &fitRange);
        attrString = nil;
        if (font)
        {
            CFRelease(font);
            font = NULL;
        }
        
        if (style)
        {
            CFRelease(style);
            style = NULL;
        }
        
        if (framesetter)
        {
            CFRelease(framesetter);
            framesetter = NULL;
        }
        
        return (sugframeSize.height + 2 * self.yOffSet);
    }
}

- (NSString *)retrieveContentAtIndex:(NSInteger)index
{
    NSInteger allRows = ceil((double)self.content.length / kNumsofCharactersPerCell);
    if (allRows == 0)
    {
        return @"";
    }

    NSInteger length = 0;
    if (index < (allRows - 1))
    {
        length = kNumsofCharactersPerCell;
    }
    else
    {
        length = MIN((self.content.length - (allRows - 1) * kNumsofCharactersPerCell), kNumsofCharactersPerCell);
    }
    length = (length < 0 ? 0 : length);
    
    return [self.content substringWithRange:NSMakeRange((index * kNumsofCharactersPerCell), length)];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.heightList objectAtIndex:indexPath.section] floatValue];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ceil((double)self.content.length / kNumsofCharactersPerCell);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTextRow";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        CTView *subView = [[CTView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   Main_Screen_Width,
                                                                   cell.contentView.frame.size.height)];
        subView.backgroundColor = [UIColor whiteColor];
        subView.tag = 100;
        [cell.contentView addSubview:subView];
        [cell.contentView sizeToFit];
        
       // NSLog(@"--- create new cell ----");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CTView *rowView = (CTView *)[cell viewWithTag:100];
    
    rowView.xOffSet     = self.xOffSet;
    rowView.yOffSet     = self.yOffSet;
    rowView.lineSpace   = self.lineSpace;
    rowView.fontSize    = self.fontSize;
    rowView.content     = [self retrieveContentAtIndex:indexPath.section];
    rowView.frame = CGRectMake(rowView.frame.origin.x,
                               rowView.frame.origin.y,
                               rowView.frame.size.width,
                               [[self.heightList objectAtIndex:indexPath.section] floatValue]);
    [cell.contentView sizeToFit];
    
    return cell;
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.richViewdelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.richViewdelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.richViewdelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.richViewdelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.richViewdelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.richViewdelegate scrollViewWillBeginDragging:scrollView];
    }
}

@end
