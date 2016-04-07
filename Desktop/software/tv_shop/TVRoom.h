//
//  TVRoom.h
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVRoom : NSObject

@property (retain, nonatomic) NSString *roomId;         //房间id
@property (retain, nonatomic) NSString *roomName;       //房间名
@property (retain, nonatomic) NSString *roomPic;        //房间封面

@property (retain, nonatomic) NSString *liveId;         //直播id
@property (retain, nonatomic) NSString *liveTitle;      //直播标题
@property (retain, nonatomic) NSString *liveTime;       //直播剩余时间
@property (retain, nonatomic) NSString *viewerCount;    //观看人数
@property (retain, nonatomic) NSString *livePic;        //直播截图
@property (retain, nonatomic) NSString *isLive;         //是否正在直播

@property (retain, nonatomic) NSString *userId;         //主播id
@property (retain, nonatomic) NSString *userName;       //主播昵称
@property (retain, nonatomic) NSString *userPic;        //主播头像
@property (retain, nonatomic) NSString *userAddr;       //主播所在地
@property (retain, nonatomic) NSString *userFaceLevel;  //主播颜值

@property (retain, nonatomic) NSString *isAttetion;     //当前房间的当前主播是否被当前登录的用户关注

-(TVRoom*)setValueWithData:(NSDictionary*)dic;

@end
