//
//  TimeoutManager.h
//  tv_shop
//
//  Created by oyoung on 15/12/21.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeoutManager;

@protocol TimeoutDeleagte <NSObject>

-(void)timeoutDidStart:(TimeoutManager *)manager;

@end


@interface TimeoutManager : NSObject

@property (weak, nonatomic) id<TimeoutDeleagte> delegate;

-(void)startWaitTimeout:(CGFloat)wait done:(void (^)(void))done;
-(void)startWaitTimeout:(CGFloat)wait;
-(void)cancelTimeoutOperation;
@end
