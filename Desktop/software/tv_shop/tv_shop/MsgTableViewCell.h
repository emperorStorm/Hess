//
//  MsgTableViewCell.h
//  tv_shop
//
//  Created by mac on 15/11/2.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *msgFrom;
@property (weak, nonatomic) IBOutlet UILabel *msgContent;

+(NSString*)ID;
-(void)setCellValue:(NSDictionary*)msg;

@end
