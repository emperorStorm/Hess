//
//  Love.h
//  tv_shop
//
//  Created by mac on 15/12/21.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Love : NSObject

+(void)timerWithLove:(UIButton *)_btnLove loveID:(int)loveID view:(UIView *)view time:(CGFloat)time cycle:(BOOL) cycle;
+(void)loveClic:(NSTimer *)timer;

@end
