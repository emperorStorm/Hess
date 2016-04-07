//
//  @protocol ChangeStatusDelegate <NSObject>  -(void)ChangeStatusWithId:(NSString *)attentionId; ChangeStatusDelegate.h
//  tv_shop
//
//  Created by oyoung on 15/12/3.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChangeStatusDelegate <NSObject>

-(void)ChangeStatusWithId:(NSString *)attentionId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success;

@end