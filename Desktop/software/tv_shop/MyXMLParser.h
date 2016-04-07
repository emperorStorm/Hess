//
//  MyXMLParser.h
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyXMLParser : NSXMLParser<NSXMLParserDelegate>

@property (retain, nonatomic) NSMutableArray *parserObjects;
@property (retain, nonatomic) NSMutableString *currentText;
@property (retain, nonatomic) NSMutableDictionary *tempDic;
@property (retain, nonatomic) NSString *currentElementName;
@property (retain, nonatomic) NSString *data;

@property (retain, nonatomic) NSMutableDictionary *returnDic;//xml装换后的结果

-(BOOL)parser:(NSXMLParser*)par;
+(MyXMLParser*)createParser;

@end
