//
//  ViewController.h
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeginBtnView.h"

@interface MainViewController : UITabBarController<MyBarButtonItemDelegate>

-(void)updateTabBarHidden:(BOOL)hidden;

@end

