//
//  TimeoutManager.m
//  tv_shop
//
//  Created by oyoung on 15/12/21.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "TimeoutManager.h"

typedef NS_ENUM(NSUInteger, TimeoutOperationType) {
    TimeoutOperationUseBlock = 0,
    TimeoutOperationUseDelegate = 1,
} ;

@implementation TimeoutManager
{
    TimeoutOperationType operationType;
    BOOL operationCancelled;
}
@synthesize delegate;

-(void)startWaitTimeout:(CGFloat)wait
{
    operationCancelled = NO;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, wait * 1000 * NSEC_PER_MSEC);
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [self operation];
    });
}

-(void)startWaitTimeout:(CGFloat)wait done:(void (^)(void))done
{
    operationCancelled = NO;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, wait * 1000 * NSEC_PER_MSEC);
    dispatch_after(when, dispatch_get_main_queue(), ^{
        if(!operationCancelled) done();
    });
}

-(void)cancelTimeoutOperation
{
    operationCancelled = YES;
}
-(void)setDelegate:(id<TimeoutDeleagte>)d {
    operationType = TimeoutOperationUseDelegate;
    delegate = d;
}



-(void)operation {
    if (!operationCancelled) {
        switch (operationType) {
            case TimeoutOperationUseBlock://bug exsist
                break;
            case TimeoutOperationUseDelegate:
                [delegate timeoutDidStart:self];
            default:
                break;
        }
    }
}

@end
