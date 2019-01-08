//
//  SNScrollView.h
//  SNIndexedScroller
//
//  Created by Sergey Petrov on 9/18/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNScrollableItem.h"


@protocol SNScrollViewDelegate <NSObject>

- (void)didFinishLoadWebView:(UIWebView *)webView contentHight:(CGFloat)contentHeight;

@end


@interface SNScrollView : UIView <UIScrollViewDelegate, UIWebViewDelegate, SNScrollableItemDelegate>


@property float contentHeight;
// Show content from file
- (void)showContentWithFile:(NSString *)filename;

// Show content from string
- (void)showContentWithString:(NSString *)content;

-(void)showcontentWithModelString:(NSString *)content;

// Set section ID tag labels throughout the content document
- (void)setupSectionID:(NSString *)sectionid;

// Set scroller color with alpha
- (void)setColorScroller:(UIColor *)color withAlpha:(float)alpha;

// Set section dot color with alpha
- (void)setColorSectionDot:(UIColor *)color withAlpha:(float)alpha;

// Set accessory view color with alpha
- (void)setColorAccessoryView:(UIColor *)color withAlpha:(float)alpha;

// Set accessory view font & color
- (void)setFontAccessoryView:(UIFont *)font withColor:(UIColor *)color;

@property (weak, nonatomic) id<SNScrollViewDelegate> delegate;

@property (nonatomic,assign) CGFloat fontsize;

-(void)reload;
@end
