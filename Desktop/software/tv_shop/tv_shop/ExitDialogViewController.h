//
//  ExitDialogViewController.h
//  tv_shop
//
//  Created by mac on 15/10/27.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "KGModal.h"
#import "PlayViewController.h"

@interface ExitDialogViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelExitBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
- (IBAction)cancelExit:(UIButton *)sender;
- (IBAction)exit:(UIButton *)sender;
@property (retain, nonatomic) KGModal *kgModal;
@property (retain, nonatomic) PlayViewController *baseController;
@property (retain, nonatomic) UINavigationController *nav;

@end
