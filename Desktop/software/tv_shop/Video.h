//
//  Video.h
//  tv_shop
//
//  Created by mac on 15/11/3.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "TVRoom.h"

@interface Video : TVRoom

@property (retain, nonatomic) NSString *clipId;         //回放影片id
@property (retain, nonatomic) NSString *privacyType;    //回放权限
@property (retain, nonatomic) NSString *isRed;          //编辑模式下是否选中

-(Video*)setValueWithData:(NSDictionary*)dic;
+(NSMutableArray*)saveToModelWithArr:(NSArray*)arr;

@end
