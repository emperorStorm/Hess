//
//  Love.m
//  tv_shop
//
//  Created by mac on 15/12/21.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//
#define imageLoveID arc4random_uniform(7)

#import "Love.h"

@implementation Love
{
    NSTimer *timer;
}
/*
 *_btnLove:实行动画的按钮
 *loveID:图片名称的id
 *view:动画添加在哪个页面上
 *time:动画间隔时间
 *cycle:是否释放动画结束的图片
 */
#pragma mark 增加定时器
+(void)timerWithLove:(UIButton *)_btnLove loveID:(int)loveID view:(UIView *)view time:(CGFloat)time cycle:(BOOL)cycle
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:_btnLove forKey:@"_btnLove"];
    [dic setValue:[NSNumber numberWithInt:loveID] forKey:@"loveID"];
    [dic setObject:view forKey:@"view"];
    //爱心播放延时器（播放间隔时间）
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(loveClic:) userInfo:dic repeats:YES];
    
    if (cycle == YES) {
        int ReleaseTime = arc4random_uniform(2)+3;//随机播放爱心的时间（多久后停止定时器）
        //爱心播放时间
        [NSTimer scheduledTimerWithTimeInterval:ReleaseTime target:timer selector:@selector(invalidate) userInfo:nil repeats:NO];
    }
    
}

#pragma mark 点击屏幕播放“爱心”动画
+(void)loveClic:(NSTimer *)timer
{
    NSNumber *num = [[timer userInfo] objectForKey:@"loveID"];
    int loveID = [num integerValue];
    if (loveID == 8) {
        loveID = arc4random_uniform(7);
    }
    
    UIButton *btnLove = [[timer userInfo] objectForKey:@"_btnLove"];
    CGFloat x = btnLove.frame.origin.x;
    CGFloat y = btnLove.frame.origin.y;
    CGFloat w = btnLove.frame.size.width;
    CGFloat h = btnLove.frame.size.height;
    
    //1.创建爱心动画对象
    CALayer *love = [[CALayer alloc]init];
    NSString *loveName = [NSString stringWithFormat:@"love0%i.png",imageLoveID];
    love.contents = (__bridge id)([UIImage imageNamed:loveName].CGImage);//添加图片
    love.frame = CGRectMake(x+15,y-15, 25, 25);
    UIView *myView = [[timer userInfo] objectForKey:@"view"];
    [myView.layer addSublayer:love];
    
    //2.设置动画
    CABasicAnimation *suofang = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //设置缩放比例(开始->结束)
    suofang.fromValue = [NSNumber numberWithFloat:0.3];
    suofang.toValue = [NSNumber numberWithFloat:1];
    suofang.duration = 1;
    //设置弧形轨迹
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:love.position];
    CGPoint toPoint = CGPointMake(arc4random_uniform(w)+x+15,y-h*3);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(arc4random_uniform(w*3)+x - w,y - h)];
    //轨迹赋值给对象
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    //设置透明度
    CABasicAnimation *transparency=[CABasicAnimation animationWithKeyPath:@"opacity"];
    transparency.fromValue=[NSNumber numberWithFloat:1.0];
    transparency.toValue=[NSNumber numberWithFloat:0.0];
    transparency.duration=6;
    //组合动画
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 6;
    group.animations = @[moveAnim,suofang,transparency];
    //设置速度：快->慢->快
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //下面两句:动画结束后移除对象(停留在结束位置)
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    //3.开始动画
    [love addAnimation:group forKey:@"animation"];
    //love动画在6秒后执行removeFromSuperlayer方法（删除love对象）
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:love selector:@selector(removeFromSuperlayer) userInfo:nil repeats:NO];
}


@end
