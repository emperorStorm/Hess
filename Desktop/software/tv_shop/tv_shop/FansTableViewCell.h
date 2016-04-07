//
//  FansTableViewCell.h
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeStatusDelegate.h"
#import "MyFansViewController.h"


@interface FansTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headPic;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMotto;
@property (weak, nonatomic) IBOutlet UIImageView *userSex;
- (IBAction)changeStatus:(UIButton *)sender;
@property (retain, nonatomic) NSString *userId;
@property id<ChangeStatusDelegate> changeDelegete;
@property (weak, nonatomic) id data;

+(NSString*)ID;
-(void)setCellValue:(id)data;

@end
