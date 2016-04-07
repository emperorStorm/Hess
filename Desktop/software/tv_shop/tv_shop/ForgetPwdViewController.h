//
//  ForgetPwdViewController.h
//  tv_shop
//
//  Created by mac on 16/1/11.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//
#import "BasicViewController.h"

@interface ForgetPwdViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;//获取验证码
@property (weak, nonatomic) IBOutlet UILabel *secRunLabel;//60秒
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;//电话号码
@property (weak, nonatomic) IBOutlet UITextField *signCode;//验证码
@property (weak, nonatomic) IBOutlet UITextField *newpwd;//新密码
@property (weak, nonatomic) IBOutlet UITextField *confirmpwd;//确认密码
@property (weak, nonatomic) IBOutlet UILabel *unlike;//不一致

- (IBAction)back:(UIButton *)sender;//返回按钮
- (IBAction)getSignCode:(UIButton *)sender;//获取验证码按钮
- (IBAction)signIn:(UIButton *)sender;//确认按钮
@end
