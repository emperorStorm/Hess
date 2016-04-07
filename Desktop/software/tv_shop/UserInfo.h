//
//  UserInfo.h
//  tv_shop
//
//  Created by oyoung on 15/12/2.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfo : NSObject
@property (retain, nonatomic) NSString *UserId;
@property (retain, nonatomic) NSString *UserName;
@property (retain, nonatomic) NSString *UserSignature;
@property (retain, nonatomic) NSString *UserLevel;
@property (retain, nonatomic) NSString *UserHeadPic;
@property (retain, nonatomic) NSString *UserSpaceId;
@property (retain, nonatomic) NSString *FaceLevel;
@property (retain, nonatomic) NSString *Focus;
@property (retain, nonatomic) NSString *Fans;
@property (retain, nonatomic) NSString *BuyCount;
@property (retain, nonatomic) NSString *SellCount;
@property (retain, nonatomic) NSString *IsFocus;


-(instancetype)initWithXMLDictionary:(NSDictionary *)dict;
@end
