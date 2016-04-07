//
//  LookVideoExitView.h
//  tv_shop
//
//  Created by mac on 15/12/18.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "ViewControllerReturnDelegate.h"
#import "AttentionChangeDelegate.h"
@class TVRoom;

@interface LookVideoExitView : BasicViewController

@property (weak,nonatomic) id<AttentionChangeDelegate> attentionDelegate;
@property (weak, nonatomic) id<ViewControllerReturnDelegate> returnDelegate;
@property (weak,nonatomic) TVRoom *room;
@property (weak,nonatomic) NSString *attentionId;//主播id
@property (weak,nonatomic) IBOutlet UIButton *attention;//关注按钮
@property (weak,nonatomic) IBOutlet UIButton *homePage;//首页按钮
@property (weak,nonatomic) IBOutlet UILabel *name;//lable
@property (weak,nonatomic) IBOutlet UIButton *attHomePage;//关注后显示的首页按钮
@property (retain, nonatomic) NSString *isAttetion;
@property (retain, nonatomic) NSString *userName;//主播昵称

-(IBAction)attention:(id)sender;
-(IBAction)homePage:(id)sender;
@end
