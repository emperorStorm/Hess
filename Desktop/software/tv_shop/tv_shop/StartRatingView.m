//
//  StartRatingView.m
//  tv_shop
//
//  Created by oyoung on 15/12/7.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "StartRatingView.h"

@interface StartRatingView ()

@property (strong, nonatomic) UIView *starBackgroundView;
@property (strong, nonatomic) UIView *starForegroundView;

@end

@implementation StartRatingView

-(instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame numberOfStar:5];
}

-(instancetype)initWithFrame:(CGRect)frame numberOfStar:(NSInteger)number{
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfStar = number;
        [self setupViews];
    }
    return self;
}

-(void)setupViews {
    self.starBackgroundView = [self starViewWithImageName:kBACKGROUND_STAR];
    self.starForegroundView = [self starViewWithImageName:kFOREGROUND_STAR];
    [self addSubview:self.starBackgroundView];
    [self addSubview:self.starForegroundView];
}

-(void)setValue:(CGFloat)v withAnimation:(BOOL)animated {
    [self setValue:v withAnimation:animated completion:nil];
}

-(void)setValue:(CGFloat)v withAnimation:(BOOL)animated completion:(void (^)(BOOL))completion {
    NSAssert(v >= 0.0 && v <= 1.0, @"要求设置的值范围必须0.0 ~ 1.0");
    if (v < 0) {
        v = 0;
    }
    if (v > 1) {
        v = 1;
    }
    CGPoint origin = CGPointMake(v * self.frame.size.width, 0);
    
    if (animated) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf changeStarForegroundViewWithPoint:origin];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
    else
    {
        [self changeStarForegroundViewWithPoint:origin];
    }
}


- (void)changeStarForegroundViewWithPoint:(CGPoint)pt {
    CGPoint p = pt;
    if (p.x < 0)
    {
        p.x = 0;
    }
    
    if (p.x > self.frame.size.width)
    {
        p.x = self.frame.size.width;
    }
    
    NSString * str = [NSString stringWithFormat:@"%0.2f",p.x / self.frame.size.width];
    CGFloat v = [str floatValue];
    p.x = v * self.frame.size.width;
    self.starForegroundView.frame = CGRectMake(0, 0, p.x, self.frame.size.height);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(starRating: value:)])
    {
        [self.delegate starRating:self value:v];
    }
}

-(UIView *)starViewWithImageName:(NSString *)name {
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        imageView.frame = CGRectMake(i * frame.size.width / self.numberOfStar, 0, frame.size.width / self.numberOfStar, frame.size.height);
        [view addSubview:imageView];
    }
    return view;
}



@end
