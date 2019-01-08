//
//  CTAutoSizeView.m
//  
//
//  Created by Yaning Fan on 14-9-9.
//
//

#import "CTAutoSizeView.h"
#import <CoreText/CoreText.h>

@interface CTAutoSizeView ()

@property (nonatomic, strong) NSMutableAttributedString *attString;

@end

@implementation CTAutoSizeView

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
    _xOffSet    = 10;
    _yOffSet    = 20;
    _lineSpace  = 6;
    _fontSize   = 20;
    _content    = @"";
}

- (void)setContent:(NSString *)content
{
    if (_content != content)
    {
        _content = [content copy];
        [self buildFrame];
    }
    [self setNeedsDisplay];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self buildFrame];
    [self setNeedsDisplay];
}

- (void)setLineSpace:(CGFloat)lineSpace
{
    _lineSpace = lineSpace;
    [self buildFrame];
    [self setNeedsDisplay];
}

- (void)setXOffSet:(CGFloat)xOffSet
{
    _xOffSet = xOffSet;
    [self buildFrame];
    [self setNeedsDisplay];
}

- (void)setYOffSet:(CGFloat)yOffSet
{
    _yOffSet = yOffSet;
    [self buildFrame];
    [self setNeedsDisplay]; 
}

- (void)buildFrame
{
    @autoreleasepool {
        if (self.content == nil)
        {
            self.content = @"";
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
        
        self.attString = [[NSMutableAttributedString alloc] initWithString:self.content attributes:attrs];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self.attString));
        CFRange fitRange;
        CGSize sugframeSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                           CFRangeMake(0, self.attString.length),
                                                                           NULL,
                                                                           CGSizeMake((self.bounds.size.width - 2 * self.xOffSet), CGFLOAT_MAX),
                                                                           &fitRange);
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                MAX(20, (sugframeSize.height + 2 * self.yOffSet)));
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
    }
}

- (void)drawRect:(CGRect)rect
{
    @autoreleasepool {
        if (self.content.length == 0)
        {
            return;
        }

        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // important, flip y coordinate
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self.attString));
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectInset(self.bounds, self.xOffSet, self.yOffSet));
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attString.length), path, NULL);
        CTFrameDraw(frame, context);
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
        
        self.attString = nil;
    }
}

@end







