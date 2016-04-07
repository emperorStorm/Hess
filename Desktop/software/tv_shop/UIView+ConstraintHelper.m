//
//  UIView+ConstraintHelper.m
//  tv_shop
//
//  Created by oyoung on 15/12/16.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "UIView+ConstraintHelper.h"

@implementation UIView (ConstraintHelper)

+(CGPoint)CGRectGetCenter:(CGRect)rect {
    return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

@end
