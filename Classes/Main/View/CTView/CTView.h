//
//  CTView.h
//  
//
//  Created by Yaning Fan on 14-9-9.
//
//

#import <UIKit/UIKit.h>

@interface CTView : UIView

@property (nonatomic, assign) CGFloat  xOffSet;
@property (nonatomic, assign) CGFloat  yOffSet;
@property (nonatomic, assign) CGFloat  lineSpace;
@property (nonatomic, assign) CGFloat  fontSize;
@property (nonatomic, copy)   NSString *content;

@end

