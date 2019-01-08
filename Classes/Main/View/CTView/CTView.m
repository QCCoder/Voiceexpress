//
//  CTView.m
//  
//
//  Created by Yaning Fan on 14-9-9.
//
//

#import "CTView.h"
#import <CoreText/CoreText.h>

@implementation CTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    _xOffSet    = 5;
    _yOffSet    = 5;
    _lineSpace  = 6;
    _fontSize   = 18;
    _content    = @"";
}

- (void)setContent:(NSString *)content
{
    if (_content != content)
    {
        _content = [content copy];
    }
    [self setNeedsDisplay];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self setNeedsDisplay];
}

- (void)setLineSpace:(CGFloat)lineSpace
{
    _lineSpace = lineSpace;
    [self setNeedsDisplay];
}

- (void)setXOffSet:(CGFloat)xOffSet
{
    _xOffSet = xOffSet;
    [self setNeedsDisplay];
}

- (void)setYOffSet:(CGFloat)yOffSet
{
    _yOffSet = yOffSet;
    [self setNeedsDisplay]; 
}

- (void)drawRect:(CGRect)rect
{
    @autoreleasepool {
        if (self.content.length == 0)
        {
            return;
        }
        
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
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.content attributes:attrs];

        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // important, flip y coordinate
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectInset(self.bounds, self.xOffSet, self.yOffSet));
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);
        CTFrameDraw(frame, context);
        
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
        
        if (frame)
        {
            CFRelease(frame);
            frame = NULL;
        }
        
        if (path)
        {
            CFRelease(path);
            path = NULL;
        }
        
        if (framesetter)
        {
            CFRelease(framesetter);
            framesetter = NULL;
        }
        
        attString = nil;
    }
}

@end







