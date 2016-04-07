//
//  parserCreateLiveData.h
//  tv_shop
//
//  Created by mac on 15/10/26.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TFHpple.h"

@interface ParserCreateLiveData : NSObject

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *contArray;
@property (strong, nonatomic) NSArray *array;
//解析
-(NSMutableArray *)parserData:(NSURL *)htmlString;

@end
