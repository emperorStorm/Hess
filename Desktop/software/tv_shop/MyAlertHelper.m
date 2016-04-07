//
//  MyAlertHelper.m
//  tv_shop
//
//  Created by mac on 15/10/22.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyAlertHelper.h"

@implementation MyAlertHelper

+(void)modelWithMsg:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
