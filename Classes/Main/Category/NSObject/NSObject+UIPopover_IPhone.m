//
//  NSObject+UIPopover_IPhone.m
//  MyTest2
//
//  Created by Yaning Fan on 13-9-6.
//  Copyright (c) 2013年 Yaning Fan. All rights reserved.
//

#import "NSObject+UIPopover_IPhone.h"

@implementation UIPopoverController (overrides)

+ (BOOL)_popoversDisabled
{
    return NO;
}

@end
