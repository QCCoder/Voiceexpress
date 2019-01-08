//
//  VESiteTypeViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VESiteTypeViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *pickerView;
@property (unsafe_unretained, nonatomic) NSMutableDictionary *alertRuleDic;
- (IBAction)back;
@end
