//
//  Viewer.m
//  tv_shop
//
//  Created by mac on 15/10/31.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "Viewer.h"

@implementation Viewer

-(instancetype)init{
    self = [super init];
    self.isAttetion  = @"0";//是否关注了该观众
    self.videoCount  = @"0";//该观众直播的数量
    return self;
}

-(Viewer *)setValueWithData:(NSDictionary *)dic{
    NSLog(@"=======dic %@",dic);
    self.userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceId"]];//用户id
    self.userName = [dic objectForKey:@"AudienceName"];//用户昵称
    self.userMotto = [dic objectForKey:@"AudienceSignature"];//用户个性签名
    self.userLevel = [NSString stringWithFormat:@"V%@",[dic objectForKey:@"AudienceLevel"]];//用户等级
    self.userPic = [dic objectForKey:@"AudienceHead"];//用户头像
    self.yanZhi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceFaceLevel"]];//颜值
    self.fansCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceFans"]];//粉丝数
    self.attetionCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceFocus"]];//关注数
    
    self.isAttetion = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceIsFocus"]];
    self.videoCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"AudienceLiveNumber"]];
    
    return self;
}

+(NSMutableArray*)saveToModelWithDicarr:(NSArray*)datas{
    NSMutableArray *tempDatas = [NSMutableArray array];
    for (NSDictionary *temp in datas) {
        Viewer *viewer = [[Viewer alloc] init];
        [viewer setValueWithData:temp];
        [tempDatas addObject:viewer];
    }
    return tempDatas;
}

@end
