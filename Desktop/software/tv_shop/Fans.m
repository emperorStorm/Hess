//
//  Fans.m
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "Fans.h"

@implementation Fans

-(instancetype)init{
    self.userId         = @"0";//用户id
    self.userName       = @"";//用户昵称
    self.userMotto      = @"";//用户个性签名
    self.userLevel      = @"V0";//用户等级
    self.userPic        = @"";//用户头像
    self.userSex        = @"0";//用户性别
    self.isAttetion     = @"0";//当前用户是否关注了
    
    return self;
}

-(Fans *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"粉丝数据  dic %@",dic);
    self.userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"userId"]];//用户id
    self.userName = [dic objectForKey:@"userName"];//用户昵称
    self.userMotto = [dic objectForKey:@"userSignature"];//用户个性签名
    self.userLevel = [NSString stringWithFormat:@"V%@",[dic objectForKey:@"userLevel"]];//用户等级
    self.userPic = [dic objectForKey:@"userHeadUrl"];//用户头像
    self.userSex = [NSString stringWithFormat:@"%@",[dic objectForKey:@"userSex"]];//用户性别
    self.isAttetion = [NSString stringWithFormat:@"%@",[dic objectForKey:@"IsFocus"]];//当前用户是否关注了
    
    return self;
}

@end
