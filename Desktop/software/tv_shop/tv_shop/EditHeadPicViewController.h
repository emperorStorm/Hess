//
//  EditHeadPicViewController.h
//  tv_shop
//
//  Created by mac on 15/12/9.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@protocol ReturnHeadPicDelegate <NSObject>
-(void)returnImage:(UIImage*)image;
@end

@interface EditHeadPicViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak,nonatomic) UIImage *headPic;
@property (weak,nonatomic) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)editFinish:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backIcon;
@property (weak, nonatomic) IBOutlet UIView *editArea;
@property (retain, nonatomic) id<ReturnHeadPicDelegate> getPicDelegate;
- (IBAction)reSelect:(UIButton *)sender;

@end
