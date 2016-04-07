//
//  MyImage.m
//  tv_shop
//
//  Created by sc on 16/3/3.
//  Copyright © 2016年 peraytech. All rights reserved.
//

#import "MyImage.h"

@implementation MyImage

+ (UIImageView *)createImgViewWith:(CGRect)frame imgName:(NSString *)imgName
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:imgName];
    return imgView;
}

@end
