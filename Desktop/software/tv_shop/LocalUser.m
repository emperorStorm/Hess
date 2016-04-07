//
//  LocalUser.m
//  tv_shop
//
//  Created by mac on 15/10/22.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "LocalUser.h"

@implementation LocalUser

#define USER_ID             @"id"           //用户id
#define USER_SESSION        @"userSession"  //用户认证串
#define USER_NAME           @"name"         //用户姓名
#define USER_PHONE          @"phone"        //用户电话号
#define USER_ROOM_ID        @"roomId"       //用户的房间id
#define USER_BIND_ROOM_ID   @"bindRoomId"   //用户签约的房间id
#define USER_PRIVACY_TYPE   @"userPrivacy"  //用户的隐私类型


#pragma mark - Getting
+(NSString*)getId {
    NSString* propertyName = USER_ID;
    return [self getProperty:propertyName];
}

+(NSString*)getSession {
    NSString* propertyName = USER_SESSION;
    return [self getProperty:propertyName];
}

+(NSString*)getName {
    NSString* propertyName = USER_NAME;
    return [self getProperty:propertyName];
}

+(NSString*)getPhone {
    NSString* propertyName = USER_PHONE;
    return [self getProperty:propertyName];
}

+(NSString*)getRoomId {
    NSString* propertyName = USER_ROOM_ID;
    return [self getProperty:propertyName];
}

+(NSString*)getBindRoomId {
    NSString* propertyName = USER_BIND_ROOM_ID;
    return [self getProperty:propertyName];
}

+(NSString*)getUserPrivacy {
    NSString* propertyName = USER_PRIVACY_TYPE;
    return [self getProperty:propertyName];
}

+(NSUserDefaults*)getUserData{
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Setting
+(void)setId:(NSString*)id {
    [[self getUserData] setObject:(id) forKey:USER_ID];
}

+(void)setSession:(NSString*)session {
    [[self getUserData] setObject:(session) forKey:USER_SESSION];
}

+(void)setName:(NSString*)name {
    [[self getUserData] setObject:(name) forKey:USER_NAME];
}

+(void)setPhone:(NSString*)phone {
    [[self getUserData] setObject:phone forKey:USER_PHONE];
}

+(void)setRoomId:(NSString*)roomId {
    [[self getUserData] setObject:roomId forKey:USER_ROOM_ID];
}

+(void)setBindRoomId:(NSString*)roomId {
    [[self getUserData] setObject:roomId forKey:USER_BIND_ROOM_ID];
}

+(void)setUserPrivacy:(NSString *)privacy{
    [[self getUserData] setObject:privacy forKey:USER_PRIVACY_TYPE];
}

#pragma mark - 根据词典设置用户信息，本方法会调用下面的方法分别设置相关的变量
+(void)setUserInfo:(NSDictionary *)userInfo {
//    NSLog(@"用户信息%@",userInfo);
    NSString *userId = [userInfo objectForKey:@"UserId" ];
    NSLog(@"setting user id: %@", userId);
    if ([userId isEqual:@"(null)"] || [userId isEqual:nil]) {
        NSLog(@"setting user id: %@. returning", userId);
    }
    [self setId:userId];
    
    NSString *bindId = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"BindSpaceId"]];
    NSLog(@"setting user bind room id: %@", bindId);
    [self setBindRoomId:bindId];
    
    NSString *phone = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"CellPhone"]];
    NSLog(@"setting user phone: %@", phone);
    [self setPhone:phone];
    
    NSString *sessionKey = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"SessionKey"]];
    NSLog(@"setting user session: %@", sessionKey);
    [self setSession:sessionKey];
    
    NSString *name = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UserName"]];
    NSLog(@"setting user name: %@", name);
    [self setName:name];
    
    NSString *roomId = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UserSpaceId"]];
    NSLog(@"setting user room id: %@", roomId);
    [self setRoomId:roomId];
    
    NSLog(@"setting default privacy: %@", @"0");
    [self setUserPrivacy:@"0"];
}

#pragma mark 第三方登录用户设置
+(void)setThree:(NSDictionary *)userInfo {
    NSString *userId = [[userInfo objectForKey:@"UserId" ] objectForKey:@"text"];
    if ([userId isEqual:@"(null)"] || [userId isEqual:nil]) {
        NSLog(@"setting user id: %@. returning", userId);
    }
    [self setId:userId];
    
    NSString *bindId = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"BindSpaceId"]];
    [self setBindRoomId:bindId];
    
    [self setPhone:nil];
    
    NSString *sessionKey = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"SessionKey"] objectForKey:@"text"]];
    [self setSession:sessionKey];
    
    NSString *name = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"UserName"] objectForKey:@"text"]];
    [self setName:name];
    
    NSString *roomId = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"UserSpaceId"] objectForKey:@"text"]];
    [self setRoomId:roomId];
    
    NSLog(@"setting default privacy: %@", @"0");
    [self setUserPrivacy:@"0"];
}


#pragma mark - 用户是否存在
+(BOOL)isUserExist {
    NSString *userId = [self getId];
    if (userId != nil) {
        return YES;
    } else {
        return NO;
    }
}

+(NSString*)getProperty:(NSString*)propertyName {
    NSString* propertyValue = [[self getUserData] objectForKey:propertyName];
    if([propertyValue isEqual:nil]) {
        NSException *e = [NSException
                          exceptionWithName: @"PropertyNotSetException"
                          reason: [NSString stringWithFormat:@"无法获得属性 - 没有设置本地用户的%@", propertyName]
                          userInfo: nil];
        @throw e;
    }
    return propertyValue;
}

+(void)clear {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
