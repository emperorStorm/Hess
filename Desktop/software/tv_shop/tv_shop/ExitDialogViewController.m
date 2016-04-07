//
//  ExitDialogViewController.m
//  tv_shop
//
//  Created by mac on 15/10/27.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "ExitDialogViewController.h"
#import "MainViewController.h"

@interface ExitDialogViewController ()

@end

@implementation ExitDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.view borderColor:nil borderWidth:0 masks:YES cornerRadius:5];
    [self setBoundsWithView:self.cancelExitBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:5];
    [self setBoundsWithView:self.exitBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:5];
    
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

- (IBAction)cancelExit:(UIButton *)sender {
    [self.kgModal hideAnimated:YES];
}

- (IBAction)exit:(UIButton *)sender {
    [self.baseController stopLive:nil];
//    [self.baseController.tabBarController setSelectedIndex:0];
//    [self.baseController.tabBarController.tabBar setHidden:NO];
//    [self.nav popToRootViewControllerAnimated:NO];
//    NSLog(@"=======%@",self.nav);
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *homeController = (MainViewController*)[board instantiateViewControllerWithIdentifier:@"Main"];
    [ApplicationDelegate.window setRootViewController:homeController];
    [self.kgModal hideAnimated:YES];
}
@end
