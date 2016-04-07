//
//  VodInfo.m
//  tv_shop
//
//  Created by oyoung on 15/12/2.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "VodInfo.h"

@implementation VodInfo

//
//@property (retain, nonatomic) NSNumber *currentPage;
//@property (retain, nonatomic) NSNumber *pageCount;
//@property (retain, nonatomic) NSNumber *LiveId;
//@property (retain, nonatomic) NSString *LivePic;
//@property (retain, nonatomic) NSString *LiveTitle;
//@property (retain, nonatomic) NSString *LiveTime;
//@property (retain, nonatomic) NSString *LiveUserName;
//@property (retain, nonatomic) NSNumber *LiveUserId;
//@property (retain, nonatomic) NSNumber *ClipId;
//@property (retain, nonatomic) NSNumber *PrivacyType;

-(instancetype)init {
    self = [super init];
    if (self) {
        self.currentPage    = @"1";
        self.pageCount      = @"1";
        self.LiveId         = @"0";
        self.LivePic        = @"";
        self.LiveTitle      = @"";
        self.LiveTime       = @"";
        self.LiveUserName   = @"";
        self.LiveUserId     = @"0";
        self.ClipId         = @"0";
        self.PrivacyType    = @"0";
    }
    return self;
}

-(instancetype)initWithXMLDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.currentPage    = dict[@"currentPage"][@"text"];
        self.pageCount      = dict[@"pageCount"][@"text"];
        self.LiveId         = dict[@"LiveId"][@"text"];
        self.LivePic        = dict[@"LivePic"][@"text"];
        self.LiveTitle      = dict[@"LiveTitle"][@"text"] ? dict[@"LiveTitle"][@"text"] : @"";
        self.LiveTime       = dict[@"LiveTime"][@"text"];
        self.LiveUserName   = dict[@"LiveUserName"][@"text"];
        self.LiveUserId     = dict[@"LiveUserId"][@"text"];
        self.ClipId         = dict[@"ClipId"][@"text"];
        self.PrivacyType    = dict[@"PrivacyType"][@"text"];
    }
    return self;
}

@end
