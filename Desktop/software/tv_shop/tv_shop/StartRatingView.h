//
//  StartRatingView.h
//  tv_shop
//
//  Created by oyoung on 15/12/7.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kBACKGROUND_STAR @"hstar_icon.png"
#define kFOREGROUND_STAR @"shower_star.png"
#define kNUMBER_OF_STAR  5


@class StartRatingView;
@protocol StartRatingDelegate <NSObject>

@optional
-(void)starRating:(StartRatingView *)view value:(CGFloat)value;


@end

@interface StartRatingView : UIView

@property (nonatomic, readonly) NSInteger numberOfStar;
@property (weak, nonatomic) id<StartRatingDelegate> delegate;


-(instancetype)initWithFrame:(CGRect)frame numberOfStar:(NSInteger) number;

-(void)setValue:(CGFloat)v withAnimation:(BOOL)animated;

-(void)setValue:(CGFloat)v withAnimation:(BOOL)animated completion:(void (^)(BOOL))completion ;

@end
