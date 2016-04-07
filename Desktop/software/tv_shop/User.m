//
//  User.m
//  tv_shop
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)init{
    self.userId         = @"0";//用户id
    self.userName       = @"";//用户昵称
    self.userMotto      = @"";//用户个性签名
    self.userLevel      = @"V0";//用户等级
    self.userPic        = @"";//用户头像
    self.roomId         = @"0";//房间id
    self.yanZhi         = @"0";//颜值
    self.buyCount       = @"0";//买入数
    self.sellCount      = @"0";//卖出数
    self.fansCount      = @"0";//粉丝数
    self.attetionCount  = @"0";//关注数
    self.userSex        = @"";//用户性别
    self.userPhone      = @"";//用户手机
    self.userAddr       = @"";//用户地址
    self.userEmail      = @"";//用户邮箱
    self.liveCount      = @"";//用户直播总数量
    
    return self;
}

-(User *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"=======dic %@",dic);
    self.userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserId"]];//用户id
    self.userName = [dic objectForKey:@"UserName"];//用户昵称
    self.userMotto = [dic objectForKey:@"UserSignature"];//用户个性签名
    self.userLevel = [NSString stringWithFormat:@"V%@",[dic objectForKey:@"UserLevel"]];//用户等级
    self.userPic = [dic objectForKey:@"UserHeadPic"];//用户头像
    self.roomId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserSpaceId"]];//房间id
    self.yanZhi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"FaceLevel"]];//颜值
    self.buyCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"BuyCount"]];//买入数
    self.sellCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"SellCount"]];//卖出数
    self.fansCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"Fans"]];//粉丝数
    self.attetionCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"Focus"]];//关注数
    self.userSex = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserSex"]];//用户性别
    self.userPhone = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserCellPhone"]];//用户手机
    self.userAddr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserAddress"]];//用户地址
    self.userEmail = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UserEmail"]];//用户地址
    self.liveCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"LiveCount"]];//用户直播总数量
    return self;
}

@end
