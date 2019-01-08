//
//  VETableViewCell.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-17.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VETableViewCell.h"


@interface VETableViewCell ()


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UILabel *groupTitleLabel;

@property (nonatomic,assign) NSInteger index;
@end

@implementation VETableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.deleteBtn setImage:Image(Icon_Delete) forState:UIControlStateNormal];
    [_favoriteBtn setImage:[QCZipImageTool imageNamed:@"icon_nofavourite2.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[QCZipImageTool imageNamed:@"icon_favourite2.png"] forState:UIControlStateSelected];
    [_favoriteBtn addTarget:self action:@selector(doFavoriteAction) forControlEvents:UIControlEventTouchUpInside];
}


+(instancetype)cellWithTableView:(UITableView *)tableView index:(NSInteger)index indentifier:(NSString *)indentifier{
    VETableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    cell.index = index;
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:@"VETableViewCell" owner:self options:nil];
        cell = [cellNib objectAtIndex:index];
    }
    return cell;
}

-(void)setGroupMember:(GroupMember *)groupMember{
    _groupMember = groupMember;
    if (groupMember.isSelected) {
        _selectBtn.image = [QCZipImageTool imageNamed:@"icon_check_selected.pdf"];
    }else{
        _selectBtn.image = [QCZipImageTool imageNamed:@"icon_check_normal.pdf"];
    }
    if (_index == VETableViewCellContactIndex) {
        
        _titleLabel.text = groupMember.name;
        _favoriteBtn.selected = groupMember.isContact;
    }else{
        _thirdTitleLabel.text = groupMember.name;
    }
    
    
}

-(void)doFavoriteAction{
    if (self.doFavorite) {
        self.doFavorite(_groupMember,_indexPath,_indicator);
    }
}


#pragma mark 联系人管理
-(void)setGroup:(Group *)group{
    _group = group;
    _groupTitleLabel.text = group.groupName;
}

- (IBAction)deleteGroup:(id)sender {
    if (self.deleteGroupItem) {
        self.deleteGroupItem();
    }
}
- (IBAction)showAllContacts:(id)sender {
    UIButton *btn = sender;
    if (self.showAll) {
        self.showAll(btn);
    }
}



@end
