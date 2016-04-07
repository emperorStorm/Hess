//
//  ShareViewController.h
//  tv_shop
//
//  Created by mac on 16/1/25.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

- (IBAction)qqShare:(UIButton *)sender;
- (IBAction)weixinShare:(UIButton *)sender;
- (IBAction)sinaShare:(UIButton *)sender;
- (void)shareWithFrame:(UIButton *)shareBtn;
@end
