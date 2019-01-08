//
//  HomeCollectionViewCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/4/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@interface HomeCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleView;

@end

@implementation HomeCollectionViewCell

+(instancetype)cell:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"HomeCollectionViewCell";
    
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    return cell;
}

-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    
    self.titleView.text = dict[@"title"];
    
    self.iconView.image = [UIImage imageNamed:dict[@"icon"]];
}
@end
