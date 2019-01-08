//
//  VEImageDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-1-6.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEImageDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface VEImageDetailViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView   *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView  *scrollView;
@end

@implementation VEImageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(back)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([self.imageURL hasPrefix:@"http"])
        {
            [self.imageView imageWithUrlStr:self.imageURL phImage:Image(Icon_Picture_Min)];
            
        }
        else
        {
            self.imageView.image = [[UIImage alloc] initWithContentsOfFile:self.imageURL];
        }
        
        self.scrollView.contentSize = self.imageView.bounds.size;
        self.scrollView.delegate = self;
    }];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
