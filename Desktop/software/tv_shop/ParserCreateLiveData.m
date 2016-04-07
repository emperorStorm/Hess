//
//  parserCreateLiveData.m
//  tv_shop
//
//  Created by mac on 15/10/26.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "ParserCreateLiveData.h"

@implementation ParserCreateLiveData

#pragma  title
-(NSArray *)parserData:(NSURL *)urlString{
    _titleArray=[[NSMutableArray alloc]init];
    NSString *data=[NSString stringWithContentsOfURL:urlString encoding:NSUTF8StringEncoding/*CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)*/error:nil];
    NSMutableString *status = [self getOneDataWithStr:data key:@"Result"];
    NSMutableString *cid = [self getOneDataWithStr:data key:@"Description"];
    [_titleArray addObject:status];
    [_titleArray addObject:cid];
    return _titleArray;
}

-(NSMutableString *)getOneDataWithStr:(NSString*)dataUrl key:(NSString*)key{
    NSLog(@"title%@",dataUrl);
    NSRange range=[dataUrl rangeOfString:[NSString stringWithFormat:@"<%@>",key]];
    NSMutableString *needTidyString=[NSMutableString stringWithString:[dataUrl substringFromIndex:range.location+range.length]];
    NSLog(@"%@",needTidyString);
    NSRange rang2=[needTidyString rangeOfString:[NSString stringWithFormat:@"</%@>",key]];
    NSMutableString *result=[NSMutableString stringWithString:[needTidyString substringToIndex:rang2.location]];
    NSLog(@"%@",result);
    return result;
}

@end
