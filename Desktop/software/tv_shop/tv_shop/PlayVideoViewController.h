//
//  PlayVideoViewController.h
//  tv_shop
//
//  Created by mac on 15/11/11.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "Video.h"
#import "YDSlider.h"
#import "ViewControllerReturnDelegate.h"
#define YDIMG(__name) [UIImage imageNamed:__name]
@interface PlayVideoViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIView *container;
@property (retain, nonatomic) Video *video;

- (IBAction)back:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
- (IBAction)playControl:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *playControlBtn;
@property (weak, nonatomic) IBOutlet YDSlider *sliderControl;
- (IBAction)valueChange:(YDSlider*)sender;

@property (weak, nonatomic) id<ViewControllerReturnDelegate> returnDelegate;

@end
