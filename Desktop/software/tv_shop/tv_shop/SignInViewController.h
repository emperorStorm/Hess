//
//  SignInViewController.h
//  tv_shop
//
//  Created by mac on 15/10/22.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface SignInViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIView *signInfo;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *weixinBtn;
- (IBAction)back:(UIButton *)sender;
- (IBAction)login:(UIButton *)sender;
- (IBAction)getSignCode:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
- (IBAction)signIn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *signCode;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UILabel *secRunLabel;

@end
