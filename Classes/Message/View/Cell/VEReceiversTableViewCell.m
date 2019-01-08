//
//  VEReceiversTableViewCell.m
//  voiceexpress
//
//  Created by fan on 15/1/19.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEReceiversTableViewCell.h"

@interface VEReceiversTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *receiver1;
@property (weak, nonatomic) IBOutlet UIImageView *receiverRead1;

@property (weak, nonatomic) IBOutlet UILabel *receiver2;
@property (weak, nonatomic) IBOutlet UIImageView *receiverRead2;

@end

@implementation VEReceiversTableViewCell

+(instancetype)cellWithTable:(UITableView *)tableView{
    
    VEReceiversTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KNibName_Receivers];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:KNibName_Receivers owner:self options:nil][0];
    }
    return cell;
}

-(void)setReceivers:(NSArray *)receivers{
    _receivers = receivers;
    
    for (int i = 0; i < receivers.count; i++) {
        Receiver *receiver = receivers[i];
        NSString *readImage = @"";
        if (receiver.isRead) {
            readImage = @"read.png";
        }else{
            readImage = @"unread.png";
        }
        if (i == 0) {
            self.receiver1.text = receiver.name;
            self.receiverRead1.image = [QCZipImageTool imageNamed:readImage];
            
            self.receiver1.ve_width = [receiver.name sizeWithAttributes:@{NSFontAttributeName:self.receiver1.font}].width;
            self.receiverRead1.ve_x = CGRectGetMaxX(self.receiver1.frame) + 2;
        }else{
            self.receiver2.text = receiver.name;
            self.receiverRead2.image = [QCZipImageTool imageNamed:readImage];
            
            self.receiver2.ve_width = [receiver.name sizeWithAttributes:@{NSFontAttributeName:self.receiver2.font}].width;
            self.receiverRead2.ve_x = CGRectGetMaxX(self.receiver2.frame) + 2;
        }
    }
}
@end
