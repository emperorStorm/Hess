//
//  Viewer.h
//  tv_shop
//
//  Created by mac on 15/10/31.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "User.h"

@interface Viewer : User

@property (retain, nonatomic) NSString *isAttetion;      //是否关注了该观众
@property (retain, nonatomic) NSString *videoCount;      //该观众直播的数量

+(NSMutableArray*)saveToModelWithDicarr:(NSArray*)datas;

@end
