//
//  CircleCollectionViewCell.m
//  voiceexpress
//
//  Created by cyyun on 16/5/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "CircleCollectionViewCell.h"
#import "CircleSubTitleLabel.h"
@interface CircleCollectionViewCell ()

@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UILabel *typeLab;
@property (nonatomic, strong) CircleSubTitleLabel *circleLab;
@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) NSArray        *sliceColors;
@property (nonatomic, strong) NSMutableArray *itemLabelList;


@end

@implementation CircleCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.circleChart = [[CircleChart alloc] initWithFrame:self.bounds Center:CGPointZero Radius:self.frame.size.width / 2.0];
        [self.circleChart setDataSource:self];
        [self.circleChart setStartPieAngle:M_PI_2];
        [self.circleChart setAnimationSpeed:0.1];
        [self.circleChart setShowLabel:NO];
        [self.circleChart setPieBackgroundColor:RGBCOLOR(149, 189, 201)];
        [self.circleChart setPieCenter:CGPointMake(self.circleChart.frame.size.width/2, self.circleChart.frame.size.height/2)];
        [self.circleChart setUserInteractionEnabled:NO];
        [self.circleChart setLabelShadowColor:[UIColor blackColor]];
        [self.contentView addSubview:self.circleChart];
        
        
        self.detailView = [[UIView alloc] init];
        self.detailView.layer.masksToBounds = YES;
        if (Main_Screen_Height == 568) {
            [self.detailView setFrame:CGRectMake(0, 0, self.circleChart.frame.size.width/1.15, self.circleChart.frame.size.height/1.15)];
        }else{
           [self.detailView setFrame:CGRectMake(0, 0, self.circleChart.frame.size.width/1.2, self.circleChart.frame.size.height/1.2)];
        }
        [self.detailView setCenter:CGPointMake(self.circleChart.frame.size.width/2, self.circleChart.frame.size.height/2)];
        [self.detailView.layer setCornerRadius:self.detailView.frame.size.width / 2.0];
        self.detailView.backgroundColor = RGBCOLOR(50, 125, 160);
        [self.circleChart addSubview:self.detailView];
        
        self.typeLab = [[UILabel alloc] init];
        [self.typeLab setFrame:CGRectMake(0, 20, 100, 30)];
        self.typeLab.textColor = [UIColor whiteColor];
        self.typeLab.ve_centerX = self.detailView.ve_width * 0.5;
        self.typeLab.textAlignment = NSTextAlignmentCenter;
        self.typeLab.font = [UIFont systemFontOfSize:22 * [UIScreen mainScreen].bounds.size.width / 375.0];
        [self.detailView addSubview:self.typeLab];
        
        for (int i = 0; i < 3; i++) {
            CircleSubTitleLabel *label = [[CircleSubTitleLabel alloc] init];
            [self.itemLabelList addObject:label];
            [self.detailView addSubview:label];
        }
    }
    return self;
}

-(NSMutableArray *)itemLabelList
{
    if (!_itemLabelList) {
        self.itemLabelList = [[NSMutableArray alloc]init];
    }
    return _itemLabelList;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    int i = 0;
    CGFloat labelX = 0;
    for (CircleSubTitleLabel *label in self.itemLabelList) {
        label.hidden = NO;
        label.ve_height = 15;
        NSString *str = label.title;
        label.ve_width = [str sizeWithFont:[UIFont systemFontOfSize:11]].width + 40;
        label.ve_y = CGRectGetMaxY(self.typeLab.frame) + i * 14 + 5;
        
        if (i == 0) {
            label.ve_centerX = self.detailView.ve_width / 2.0;
            labelX = label.ve_x;
        }else{
            label.ve_x = labelX;
        }
        i++;
    }
    [self.circleChart reloadData];
}

-(void)setHomeCircle:(HomeCircle *)homeCircle{
    if (_homeCircle != homeCircle) {
        _homeCircle = homeCircle;
    }
    self.sliceColors =[NSArray arrayWithObjects:
                       RGBCOLOR(250, 111, 111),
                       RGBCOLOR(232, 211, 63),
                       RGBCOLOR(16, 198, 110),nil];
    self.slices = [NSMutableArray arrayWithCapacity:3];
    for(int i = 0; i < 3; i ++)
    {
        NSNumber *one = @(0);
        switch (i) {
            case 0:
                one = (NSNumber *)homeCircle.red.numberOfNoRead;
                break;
            case 1:
                one = (NSNumber *)homeCircle.yellow.numberOfNoRead;
                break;
            case 2:
                one = (NSNumber *)homeCircle.green.numberOfNoRead;
                break;
            default:
                break;
        }
        if (one == nil) {
            return;
        }
        [_slices addObject:one];
    }
    self.typeLab.text = homeCircle.typeName;
    for (int i = 0; i < 3; i++) {
        CircleSubTitleLabel *lab = self.itemLabelList[i];
        lab.title = i == 0 ?
        homeCircle.red.title : i == 1 ?
        homeCircle.yellow.title :
        homeCircle.green.title;
        
        lab.number = i == 0 ?
        [NSString stringWithFormat:@"%.1f%%", homeCircle.red.percent] : i == 1 ?
        [NSString stringWithFormat:@"%.1f%%", homeCircle.yellow.percent] :
        [NSString stringWithFormat:@"%.1f%%", homeCircle.green.percent];
    }
    [self setNeedsLayout];
    [self.circleChart reloadData];
}

-(void)setCurrCircle:(BOOL)currCircle{
    _currCircle = currCircle;
    
    //    self.circleView.apa = _apa;
    //
    //    self.circleView.isNeedDraw = NO;
    //
    //    self.circleView.isSelected = _currCircle;
    
    if (_apa > 0.999) {
        if (self.selectedCircle) {
            self.selectedCircle(self.tag);
        }
    }
    [self.circleChart reloadData];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInCircleChart:(CircleChart *)pieChart
{
    return self.slices.count;
}

- (CGFloat)circleChart:(CircleChart *)circleChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)circleChart:(CircleChart *)circleChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)circleChart:(CircleChart *)circleChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)circleChart:(CircleChart *)circleChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
}
- (void)circleChart:(CircleChart *)circleChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",(unsigned long)index);
}
- (void)circleChart:(CircleChart *)circleChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
}

@end
