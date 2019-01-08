//
//  CTContentManager.h
//  Demo
//
//  Created by Yaning Fan on 14-9-10.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTContentManager : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGFloat   xOffSet;
@property (nonatomic, assign) CGFloat   yOffSet;
@property (nonatomic, assign) CGFloat   lineSpace;
@property (nonatomic, assign) CGFloat   fontSize;
@property (nonatomic, assign) CGFloat   viewWidth;
@property (nonatomic, copy)   NSString  *content;

@property(nonatomic, assign) id<UIScrollViewDelegate> richViewdelegate;

- (void)refreshCellHeigtList;

@end
