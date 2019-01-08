//
//  VEAddImageViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-12-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAddImageViewController.h"

@interface VEAddImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation VEAddImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 打开相册
- (IBAction)openPhotoLibrary:(id)sender
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];  
}

// 拍照
- (IBAction)takePhoto:(id)sender
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];   
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
      //  imagePicker.allowsEditing = YES;
        imagePicker.sourceType = sourceType;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error accessing media"
                                   message:@"Device doesn’t support that media source."
                                  delegate:nil
                         cancelButtonTitle:@"Drat!"
                         otherButtonTitles:nil];
        [alert show];
    }

}

- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [original drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return final;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orginalImage = info[UIImagePickerControllerOriginalImage];
   // UIImage *orginalImage = info[UIImagePickerControllerEditedImage];
    NSLog(@"orginalImage: height = %f, width = %f", orginalImage.size.height, orginalImage.size.width);
    
    UIImage *shrunkenImage = orginalImage;
    
    float scale_width = 1.0;
    float scale_height = 1.0;
    if (orginalImage.size.width > 560 && orginalImage.size.height > 420)
    {
        scale_width = 560.0f / orginalImage.size.width;
        scale_height = 420.0f / orginalImage.size.height;
        
        float scale = scale_width;
        if (scale_width < scale_height)
        {
            scale = scale_height;
        }
        
        shrunkenImage = [self shrinkImage:orginalImage toSize:CGSizeMake(scale * orginalImage.size.width, scale * orginalImage.size.height)];
    }
   
    self.imageView.image = shrunkenImage;
    NSLog(@"self.imageView.image: height = %f, width = %f", self.imageView.image.size.height, self.imageView.image.size.width);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
