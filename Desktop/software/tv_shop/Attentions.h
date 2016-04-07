//
//  Attentions.h
//  tv_shop
//
//  Created by mac on 15/10/25.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attentions : NSObject

@property (retain, nonatomic) NSString *userId;         //用户id
@property (retain, nonatomic) NSString *userName;       //用户昵称
@property (retain, nonatomic) NSString *userMotto;      //用户个性签名

@property (retain, nonatomic) NSString *userLevel;      //用户等级
@property (retain, nonatomic) NSString *userPic;        //用户头像
@property (retain, nonatomic) NSString *userSex;        //性别


-(Attentions *)setValueWithData:(NSDictionary*)dic;

@end
