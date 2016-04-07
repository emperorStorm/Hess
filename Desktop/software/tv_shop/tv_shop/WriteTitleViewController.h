//
//  WriteTitleViewController.h
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface WriteTitleViewController : BasicViewController

@property (retain,nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)reset:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *beginPlay;
- (IBAction)beginPlay:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *selectTool;
- (IBAction)selectPrivate:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *privateBtn;
@property (weak, nonatomic) IBOutlet UIButton *unPrivateBtn;

@end
