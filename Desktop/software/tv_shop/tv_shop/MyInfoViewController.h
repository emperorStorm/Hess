//
//  MyInfoViewController.h
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface MyInfoViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UILabel *userName;//姓名
@property (weak, nonatomic) IBOutlet UILabel *level;//等级
@property (weak, nonatomic) IBOutlet UIImageView *userPic;//头像
@property (weak, nonatomic) IBOutlet UILabel *mottoLabel;//个性签名
@property (weak, nonatomic) IBOutlet UILabel *attetionCount;//关注数
@property (weak, nonatomic) IBOutlet UILabel *fansCount;//粉丝数
@property (weak, nonatomic) IBOutlet UIView *yanzhiControl;//通过改变这个view的x控制颜值显示
- (IBAction)editUserInfo:(UIButton *)sender;
- (IBAction)myLiveVideo:(UIButton *)sender;
- (IBAction)myMsg:(UIButton *)sender;
- (IBAction)setting:(UIButton *)sender;
- (IBAction)showMyAttention:(UIButton *)sender;
- (IBAction)showMyFans:(UIButton *)sender;

@end
