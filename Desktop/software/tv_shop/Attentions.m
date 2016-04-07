//
//  Attentions.m
//  tv_shop
//
//  Created by mac on 15/10/25.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "Attentions.h"

@implementation Attentions

-(instancetype)init{
    self.userId         = @"0";//用户id
    self.userName       = @"";//用户昵称
    self.userMotto      = @"";//用户个性签名
    self.userLevel      = @"V0";//用户等级
    self.userPic        = @"";//用户头像
    self.userSex        = @"0";//用户性别
    
    return self;
}
-(Attentions *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"我的关注数据  dic %@",dic);
    self.userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"subscribedUserId"]];//用户id
    self.userName = [dic objectForKey:@"subscribedUserName"];//用户昵称
    self.userMotto = [dic objectForKey:@"subscribedUserSignature"];//用户个性签名
    self.userLevel = [NSString stringWithFormat:@"V%@",[dic objectForKey:@"subscribedUserLevel"]];//用户等级
    self.userPic = [dic objectForKey:@"subscribedUserHeadUrl"];//用户头像
    self.userSex = [NSString stringWithFormat:@"%@",[dic objectForKey:@"subscribedUserSex"]];//用户性别
    
    return self;
}

@end
