//
//  UserInfo.m
//  tv_shop
//
//  Created by oyoung on 15/12/2.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.UserName       = @"";
        self.UserId         = @"";
        self.UserLevel      = @"V0";
        self.UserHeadPic    = @"";
        self.UserSignature  = @"";
        self.UserSpaceId    = @"0";
        self.FaceLevel      = @"0";
        self.Focus          = @"0";
        self.Fans           = @"0";
        self.BuyCount       = @"0";
        self.SellCount      = @"0";
        self.IsFocus        = @"False";
        
    }
    return  self;
}

-(instancetype)initWithXMLDictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        self.UserName   =[NSString stringWithFormat:@"%@", [[dict objectForKey:@"UserName"] objectForKey:@"text"]];
        self.UserId     = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"UserId"] objectForKey:@"text"]];
        self.UserLevel  = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"UserLevel"] objectForKey:@"text"]];
        self.UserLevel  = [NSString stringWithFormat:@"V%@", self.UserLevel];
        if ([dict objectForKey:@"UserHeadPic"])
            self.UserHeadPic =[NSString stringWithFormat:@"%@", [[dict objectForKey:@"UserHeadPic"] objectForKey:@"text"]];
        else
            self.UserHeadPic = @"";
        if ([dict objectForKey:@"UserSignature"] )
        {
            self.UserSignature = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"UserSignature"] objectForKey:@"text"]];
            if ([self.UserSignature isEqualToString:@"(null)"]) {
                self.UserSignature = @"";
            }
        }
        else
            self.UserSignature = @"";
        
        self.FaceLevel  = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"FaceLevel"] objectForKey:@"text"]];
        self.Focus      = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"Focus"] objectForKey:@"text"]];
        self.Fans = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"Fans"] objectForKey:@"text"]];
        self.BuyCount = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"BuyCount"] objectForKey:@"text"]];
        self.SellCount = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"SellCount"] objectForKey:@"text"]];
        self.IsFocus    = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"IsFocus"] objectForKey:@"text"]];
    }
    return self;
}

@end
