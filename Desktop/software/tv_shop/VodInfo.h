//
//  VodInfo.h
//  tv_shop
//
//  Created by oyoung on 15/12/2.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VodInfo : NSObject

@property (copy, nonatomic) NSString *currentPage;
@property (copy, nonatomic) NSString *pageCount;
@property (copy, nonatomic) NSString *LiveId;
@property (copy, nonatomic) NSString *LivePic;
@property (copy, nonatomic) NSString *LiveTitle;
@property (copy, nonatomic) NSString *LiveTime;
@property (copy, nonatomic) NSString *LiveUserName;
@property (copy, nonatomic) NSString *LiveUserId;
@property (copy, nonatomic) NSString *ClipId;
@property (copy, nonatomic) NSString *PrivacyType;


-(instancetype)initWithXMLDictionary:(NSDictionary *)dictionary;

@end
