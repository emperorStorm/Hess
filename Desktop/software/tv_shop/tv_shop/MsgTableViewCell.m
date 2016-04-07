//
//  MsgTableViewCell.m
//  tv_shop
//
//  Created by mac on 15/11/2.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MsgTableViewCell.h"

@implementation MsgTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)ID{
    return @"MsgCell";
}

-(void)setCellValue:(NSDictionary *)msg{
    [self.msgFrom setText:[NSString stringWithFormat:@"%@:",msg[@"UserName"][@"text"]]];
    if ([msg[@"ChatDesc"][@"text"] isEqual:(@"送给主播一个♥")]) {
        //设置字体颜色
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:msg[@"ChatDesc"][@"text"]];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,6)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,1)];
        [self.msgContent setAttributedText:str];
    }else{
        [self.msgContent setText:msg[@"ChatDesc"][@"text"]];
    }
    
}

@end
