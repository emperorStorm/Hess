//
//  BeginBtnView.m
//  tv_shop
//
//  Created by mac on 16/1/21.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//

#import "BeginBtnView.h"

@implementation BeginBtnView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(BeginBtnView *)createBeginBtnView{
    BeginBtnView *btn = [[NSBundle mainBundle] loadNibNamed:@"BeginBtnView" owner:nil options:nil][0];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:btn.frame.size.width/2.0];
    return btn;
}
- (IBAction)clickBtn:(UIButton *)sender {
    [self.delegate buttonClick:nil];
}
@end
