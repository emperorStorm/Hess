//
//  ViewControllerReturnDelegate.h
//  tv_shop
//
//  Created by oyoung on 15/12/7.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViewControllerReturnDelegate <NSObject>

@required
-(void)returnToLastViewController:(UIViewController *)viewController;

@end
