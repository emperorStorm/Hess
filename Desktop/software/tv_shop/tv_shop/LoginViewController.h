//
//  LoginViewController.h
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface LoginViewController : BasicViewController
- (IBAction)back:(UIButton *)sender;
- (IBAction)signIn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *loginInfo;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *weixinBtn;
- (IBAction)login:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
- (IBAction)weixinLogin:(UIButton *)sender;
- (IBAction)forgetPwd:(UIButton *)sender;
- (IBAction)qqLogin:(id)sender;
- (IBAction)sinaLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *weixin;
@property (weak, nonatomic) IBOutlet UIButton *sina;
@end
