//
//  CustomCollectionViewCell.m
//  CustomLayout
//
//  Created by Fay on 16/3/12.
//  Copyright © 2016年 Fay. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@interface CustomCollectionViewCell ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;

@end

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setHomeCircle:(HomeCircle *)homeCircle{
    _homeCircle = homeCircle;
    
    self.circleView.radius = 72 * Main_Screen_Height / 667.0;
    self.circleView.lineWith = 14 * Main_Screen_Height / 667.0;
    self.circleView.title = homeCircle.typeName;
    self.circleView.isNeedDraw = YES;
    self.circleView.noRead = homeCircle.sumOfNoRead;
    self.circleView.isSelected = homeCircle.isSelected;
    self.circleView.dataList = @[homeCircle.yellow,homeCircle.green,homeCircle.red];
    [self.circleView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setCurrCircle:(BOOL)currCircle{
    _currCircle = currCircle;
    
    self.circleView.apa = _apa;
    
    self.circleView.isNeedDraw = NO;
    
    self.circleView.isSelected = _currCircle;
    
    if (_apa > 0.999) {
        if (self.selectedCircle) {
            self.selectedCircle(self.tag);
        }
    }
    
    [self.circleView reloadView];
}
@end