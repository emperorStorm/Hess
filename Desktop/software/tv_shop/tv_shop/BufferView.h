//
//  BufferView.h
//  tv_shop
//
//  Created by mac on 15/12/10.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface BufferView : UIView
+ (id) buffer:(NSString *)name imagePath:(NSString *)imagePath;

@property(weak,nonatomic) IBOutlet UILabel *lable;
@property(weak,nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;

@end
