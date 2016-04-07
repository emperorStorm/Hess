//
//  LocalUser.h
//  tv_shop
//
//  Created by mac on 15/10/22.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalUser : NSObject

#pragma mark - Getting
+(NSString*)getId;
+(NSString*)getSession;
+(NSString*)getName;
+(NSString*)getPhone;
+(NSString*)getRoomId;
+(NSString*)getBindRoomId;
+(NSString*)getUserPrivacy;//获得用户的隐私类型

#pragma mark - Setting
+(void)setId:(NSString*)id;
+(void)setSession:(NSString*)session;
+(void)setName:(NSString*)name;
+(void)setPhone:(NSString*)phone;
+(void)setRoomId:(NSString*)roomId;
+(void)setBindRoomId:(NSString*)roomId;
+(void)setUserPrivacy:(NSString*)privacy;//设置用户的隐私类型

+(void)clear;

#pragma mark - 根据词典设置用户信息，本方法会调用下面的方法分别设置相关的变量
+(void)setUserInfo:(NSDictionary*)userInfo;

#pragma mark - 用户是否存在
+(BOOL)isUserExist;

+(void)setThree:(NSDictionary *)userInfo;
@end
