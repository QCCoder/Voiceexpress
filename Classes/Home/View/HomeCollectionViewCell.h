//
//  HomeCollectionViewCell.h
//  voiceexpress
//
//  Created by 钱城 on 16/4/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) NSDictionary *dict;

+(instancetype)cell:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
