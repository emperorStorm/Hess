//
//  MyColor.h
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyColor : UIColor

/**
 * 用Hex和alpha定义颜色值。
 * @param color Hex值
 * @param alpha 0.0f - 1.0f
 *
 * @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

