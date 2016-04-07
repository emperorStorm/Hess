//
//  TVRoom.m
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "TVRoom.h"

@implementation TVRoom

-(instancetype)init{
     self.roomId = @"0";         //房间id
     self.roomName = @"";       //房间名
     self.roomPic = @"";        //房间封面
    
     self.liveId = @"0";         //直播id
     self.liveTitle = @"";      //直播标题
     self.liveTime = @"";       //直播剩余时间
     self.viewerCount = @"0";    //观看人数
     self.livePic = @"";        //直播截图
     self.isLive = @"0";        //是否正在直播
    
     self.userId = @"0";         //主播id
     self.userName = @"";       //主播昵称
     self.userPic = @"";        //主播头像
     self.userAddr = @"";       //主播所在地
     self.userFaceLevel = @"0";  //主播颜值
    
     self.isAttetion = @"False"; //当前房间的当前主播是否被当前登录的用户关注
    
    return self;
}

-(TVRoom *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"=======dic %@",dic);
    self.roomId =[NSString stringWithFormat:@"%@",
                  [dic objectForKey:@"SpaceId"]];         //房间id
    self.roomName = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"SpaceName"]];       //房间名
    self.roomPic = [NSString stringWithFormat:@"%@",
                    [dic objectForKey:@"SpaceHead"]];        //房间封面
    
    self.liveId = [NSString stringWithFormat:@"%@",
                   [dic objectForKey:@"LiveId"]];         //直播id
    self.liveTitle = [NSString stringWithFormat:@"%@",
                      [dic objectForKey:@"LiveTitle"]];      //直播标题
    self.liveTime = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"LiveTime"]];       //直播剩余时间
    self.viewerCount = [NSString stringWithFormat:@"%@",
                        [dic objectForKey:@"LiveOnlineCount"]];    //观看人数
    self.livePic = [NSString stringWithFormat:@"%@",
                    [dic objectForKey:@"LivePic"]];        //直播截图
    self.isLive = [NSString stringWithFormat:@"%@",
                    [dic objectForKey:@"IsLive"]];        //是否正在直播
    
    self.userId = [NSString stringWithFormat:@"%@",
                   [dic objectForKey:@"UserId"]];         //主播id
    self.userName = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"UserName"]];       //主播昵称
    self.userPic = [NSString stringWithFormat:@"%@",
                    [dic objectForKey:@"UserHead"]];        //主播头像
    self.userAddr = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"UserAddress"]];       //主播所在地
    self.userFaceLevel = [NSString stringWithFormat:@"%@",
                          [dic objectForKey:@"UserFaceLevel"]];  //主播颜值
    
    self.isAttetion = [NSString stringWithFormat:@"%@",[dic objectForKey:@"IsFocus"]];    //当前房间的当前主播是否被当前登录的用户关注
    
    return self;
}

@end
