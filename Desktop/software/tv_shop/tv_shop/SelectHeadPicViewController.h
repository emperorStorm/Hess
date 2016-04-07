//
//  SelectHeadPicViewController.h
//  tv_shop
//
//  Created by mac on 15/10/29.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "SetMyInfoViewController.h"
#import "KGModal.h"

@protocol CameraDelegate <NSObject>

-(void)createCameraWithMode:(NSString*)mode;

@end

@interface SelectHeadPicViewController : BasicViewController
- (IBAction)openCamera:(UIButton *)sender;
- (IBAction)openImages:(UIButton *)sender;
@property id<CameraDelegate> camera;

@end
