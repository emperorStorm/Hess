//
//  SettingViewController.h
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface SettingViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
- (IBAction)logout:(UIButton *)sender;
- (IBAction)back:(UIButton *)sender;
- (IBAction)privacySet:(UIButton *)sender;

@end
