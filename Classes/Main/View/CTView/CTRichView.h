//
//  CTRichView.h
//  
//
//  Created by Yaning Fan on 14-9-9.
//
//

#import <UIKit/UIKit.h>

@interface CTRichView : UIView

@property (nonatomic, assign) CGFloat   xOffSet;
@property (nonatomic, assign) CGFloat   yOffSet;
@property (nonatomic, assign) CGFloat   lineSpace;
@property (nonatomic, assign) CGFloat   fontSize;
@property (nonatomic, copy)   NSString  *content;

@property (nonatomic, strong) UIView    *headerView;
@property (nonatomic, strong) UIView    *footerView;
@property (nonatomic, strong) UIColor   *richViewBackgroundColor;

@property(nonatomic, assign) id<UIScrollViewDelegate> richViewdelegate;

- (void)scrollToTop;
- (CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)offset;
- (void)refreshContent;
- (CGSize)contentSize;

@end
