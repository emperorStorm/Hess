//
//  SetMyInfoViewController.h
//  tv_shop
//
//  Created by mac on 15/10/25.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface SetMyInfoViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *headPic;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPhone;
@property (weak, nonatomic) IBOutlet UITextView *userMotto;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userArea;
- (IBAction)editHeadPic:(UIButton *)sender;
- (IBAction)save:(UIButton *)sender;
- (IBAction)back:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) UIImage *headImage;
@property (weak, nonatomic) IBOutlet UIButton *manBtn;
@property (weak, nonatomic) IBOutlet UIButton *womenBtn;
- (IBAction)selectMan:(UIButton *)sender;
- (IBAction)selectWomen:(UIButton *)sender;


@end
