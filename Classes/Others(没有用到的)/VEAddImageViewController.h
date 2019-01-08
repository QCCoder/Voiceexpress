//
//  VEAddImageViewController.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-12-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEAddImageViewController : UIViewController
- (IBAction)back:(id)sender;
- (IBAction)openPhotoLibrary:(id)sender;
- (IBAction)takePhoto:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;

@end
