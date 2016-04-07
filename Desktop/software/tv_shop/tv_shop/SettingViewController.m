//
//  SettingViewController.m
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "SettingViewController.h"
#import "MainViewController.h"
#import "PrivacySetViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.logoutBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logout:(UIButton *)sender {
    [LocalUser clear];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *homeController = (MainViewController*)[board instantiateViewControllerWithIdentifier:@"Main"];
    [ApplicationDelegate.window setRootViewController:homeController];
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController.tabBarController.tabBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)privacySet:(UIButton *)sender {
//    [self showText:@"正在开发中,敬请期待..."];
    PrivacySetViewController *privacy = [[PrivacySetViewController alloc] init];
    [self.navigationController pushViewController:privacy animated:YES];
}
@end
