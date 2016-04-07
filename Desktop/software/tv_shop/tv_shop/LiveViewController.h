//
//  LiveViewController.h
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface LiveViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIButton *photograph;
@property (retain, nonatomic) UIImagePickerController *picker;
- (IBAction)back:(UIButton *)sender;
- (IBAction)changeCameraDevice:(UIButton *)sender;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
- (IBAction)cancelTakePhone:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;

@property (weak, nonatomic) IBOutlet UIImageView *selectTool;

@end
