//
//  MyXMLParser.m
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyXMLParser.h"

@implementation MyXMLParser

+(MyXMLParser *)createParser{
    static MyXMLParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[MyXMLParser alloc] init];
    });
    
    return parser;
}

-(BOOL)parser:(NSXMLParser*)par
{
    [par setDelegate:self];//设置NSXMLParser对象的解析方法代理
    return [par parse];//调用代理解析NSXMLParser对象，看解析是否成功   }
    
}

#pragma mark xmlparser
//step 1 :准备解析
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
//    NSLog(@"%@",@"准备解析");
    self.returnDic = [[NSMutableDictionary alloc] init];
    self.parserObjects = [[NSMutableArray alloc] init];
}
//step 2：准备解析节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//    NSLog(@"准备解析节点 %@",elementName);
    if ([elementName isEqualToString:@"DataInfo"]||
        [elementName isEqualToString:@"Head"]||
        [elementName isEqualToString:@"AudienceInfo"]||
        [elementName isEqualToString:@"ChatDataInfo"]) {
        self.tempDic = [[NSMutableDictionary alloc] init];
    }
    self.currentText = [[NSMutableString alloc]init];
    self.currentElementName = elementName;
}
//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    NSLog(@"===数据 %@",string);
    [self.currentText appendString:string];
}

//step 4 ：解析完当前节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:self.currentElementName]) {
        [self.tempDic setObject:self.currentText forKey:self.currentElementName];
//        NSLog(@"临时  %@",self.tempDic);
    }else if ([elementName isEqualToString:@"DataInfo"]||
              [elementName isEqualToString:@"AudienceInfo"]||
              [elementName isEqualToString:@"ChatDataInfo"]) {
        [self.parserObjects addObject:self.tempDic];
    }else if ([elementName isEqualToString:@"DataInfos"]){
        if (self.parserObjects.count!=0) {
            [self.returnDic setObject:self.parserObjects forKey:elementName];
        }
    }else if ((![elementName isEqualToString:@"AudienceList"])&&
              (![elementName isEqualToString:@"ChatList"])){
        [self.returnDic setObject:[[NSMutableDictionary alloc] initWithDictionary:self.tempDic] forKey:elementName];
//        NSLog(@"最终 %@",self.returnDic);
        [self.tempDic removeAllObjects];
    }
}

//step 5；解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//    NSLog(@"解析完成 %@",self.returnDic);
}

@end
