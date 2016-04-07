//
//  Video.m
//  tv_shop
//
//  Created by mac on 15/11/3.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "Video.h"

@implementation Video

-(instancetype)init{
    self = [super init];
    self.clipId = @"0";         //回放影片id
    self.privacyType = @"0";    //回放权限
    self.isRed = @"0";
    return self;
}

-(TVRoom *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"=======dic %@",dic);
    
    self.liveId = [NSString stringWithFormat:@"%@",
                   [dic objectForKey:@"LiveId"]];         //直播id
    self.liveTitle = [NSString stringWithFormat:@"%@",
                      [dic objectForKey:@"LiveTitle"]];      //直播标题
    self.liveTime = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"LiveTime"]];       //直播剩余时间
    self.livePic = [NSString stringWithFormat:@"%@",
                    [dic objectForKey:@"LivePic"]];        //直播截图
    
    self.userId = [NSString stringWithFormat:@"%@",
                   [dic objectForKey:@"LiveUserId"]];         //主播id
    self.userName = [NSString stringWithFormat:@"%@",
                     [dic objectForKey:@"LiveUserName"]];       //主播昵称
    
    self.clipId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ClipId"]];//回放影片id
    self.privacyType = [NSString stringWithFormat:@"%@",[dic objectForKey:@"PrivacyType"]];//回放权限
    
    return self;
}

+(NSMutableArray*)saveToModelWithArr:(NSArray *)arr{
    NSMutableArray *tempDatas = [NSMutableArray array];
    NSLog(@"返回数据%@", arr);
    for (NSDictionary *temp in arr) {
        Video *video = [[Video alloc] init];
        [video setValueWithData:temp];
        [tempDatas addObject:video];
    }
    return tempDatas;
}

@end
