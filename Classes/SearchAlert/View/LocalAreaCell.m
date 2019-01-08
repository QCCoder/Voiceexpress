//
//  LocalAreaCell.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "LocalAreaCell.h"
#import "LocalAreaAgent.h"

#define kCol 3

@implementation LocalAreaCell

+(id)cellWithTableView:(UITableView *)tableView{

    LocalAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_SearchLocalAreas];
    if (cell == nil){
        cell = (LocalAreaCell *)[[[NSBundle  mainBundle]  loadNibNamed:KIdentifier_SearchLocalAreas owner:self options:nil]  lastObject];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
@end
