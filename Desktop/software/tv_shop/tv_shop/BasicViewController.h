//
//  BasicViewController.h
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
typedef void (^NetError)(AFHTTPRequestOperation *operation, NSError *error);

@interface BasicViewController : UIViewController

@property (copy,nonatomic) NetError errorInfo;
@property (retain,nonatomic) MBProgressHUD *hud;

- (void)showTextDialog:(id)sender;
- (void)showProgressDialog:(id)sender;
- (void)showProgressDialog2:(id)sender;
- (void)showCustomDialog:(id)sender;
- (void)showText:(id)sender;


- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition;
-(void)setBoundsWithView:(UIView*)view borderColor:(CGColorRef)cgColor borderWidth:(CGFloat)width masks:(BOOL)isBounds cornerRadius:(CGFloat)radius;
-(BOOL) isValidateMobile:(NSString *)mobile;
-(BOOL) isValidateEmail:(NSString *)Email;
//处理照相机的图片被旋转90度的问题
- (UIImage *)fixOrientation:(UIImage *)aImage;
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
