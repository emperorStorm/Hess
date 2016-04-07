//
//  LookVideoExitView.m
//  tv_shop
//
//  Created by mac on 15/12/18.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "LookVideoExitView.h"
#import "XMLReader.h"
#import "TVRoom.h"
#import "User.h"

@implementation LookVideoExitView

-(void)viewDidLoad{
    [super viewDidLoad];
    //设置圆角
    [self setBoundsWithView:self.attention borderColor:[UIColor whiteColor].CGColor borderWidth:1 masks:YES cornerRadius:20];
    [self setBoundsWithView:self.homePage borderColor:[UIColor whiteColor].CGColor borderWidth:1 masks:YES cornerRadius:20];
    [self setBoundsWithView:self.attHomePage borderColor:[UIColor whiteColor].CGColor borderWidth:1 masks:YES cornerRadius:20];
}
#pragma mark 页面即将打开
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.name.text = [NSString stringWithFormat:@"%@的直播已结束",self.room.userName];
    //判断是否已经关注
//    User *oneSelf = [[User alloc]init];
    if (self.room.userId != [LocalUser getId] && [self.room.isAttetion isEqual:@"False"]) {
        [self.attHomePage setHidden:YES];
    }else{
        [self.attention setHidden:YES];
        [self.homePage setHidden:YES];
    }
}

#pragma mark 关注
- (void)attention:(id)sender
{
    [self.attentionDelegate AttentionChange:self.room.userId];
    [self.returnDelegate returnToLastViewController:self];
}

#pragma mark 首页
- (IBAction)homePage:(id)sender
{
    [self.returnDelegate returnToLastViewController:self];
}
@end
