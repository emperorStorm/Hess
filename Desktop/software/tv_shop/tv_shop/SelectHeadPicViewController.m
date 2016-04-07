//
//  SelectHeadPicViewController.m
//  tv_shop
//
//  Created by mac on 15/10/29.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "SelectHeadPicViewController.h"

@interface SelectHeadPicViewController ()

@end

@implementation SelectHeadPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.view borderColor:nil borderWidth:0 masks:YES cornerRadius:5];
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

- (IBAction)openCamera:(UIButton *)sender {
    [self.camera createCameraWithMode:@"Camera"];
}

- (IBAction)openImages:(UIButton *)sender {
    [self.camera createCameraWithMode:@"Photo"];
}

@end
