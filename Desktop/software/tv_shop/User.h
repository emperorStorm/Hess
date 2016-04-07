//
//  User.h
//  tv_shop
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (retain, nonatomic) NSString *userId;         //用户id
@property (retain, nonatomic) NSString *userName;       //用户昵称
@property (retain, nonatomic) NSString *userMotto;      //用户个性签名

@property (retain, nonatomic) NSString *userLevel;      //用户等级
@property (retain, nonatomic) NSString *userPic;        //用户头像
@property (retain, nonatomic) NSString *roomId;         //房间id
@property (retain, nonatomic) NSString *yanZhi;         //颜值
@property (retain, nonatomic) NSString *buyCount;       //买入数

@property (retain, nonatomic) NSString *sellCount;      //卖出数
@property (retain, nonatomic) NSString *fansCount;      //粉丝数
@property (retain, nonatomic) NSString *attetionCount;  //关注数

@property (retain, nonatomic) NSString *userSex;        //用户性别
@property (retain, nonatomic) NSString *userPhone;      //用户手机号
@property (retain, nonatomic) NSString *userAddr;       //用户地址
@property (retain, nonatomic) NSString *userEmail;      //用户邮箱

@property (retain, nonatomic) NSString *liveCount;      //用户直播总数量

-(User*)setValueWithData:(NSDictionary*)dic;

@end
