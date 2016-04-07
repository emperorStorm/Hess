//
//  LookVideoViewController.h
//  tv_shop
//
//  Created by mac on 15/10/28.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "ViewControllerReturnDelegate.h"
#import "TVRoom.h"

@interface LookVideoViewController : BasicViewController

@property (retain, nonatomic) TVRoom *room;
@property (assign, nonatomic) BOOL shareReturn;//分享之后返回页面
@property (weak, nonatomic) IBOutlet UIView *playerHeadView;
- (IBAction)openSendView:(UIButton *)sender;
- (IBAction)sendMsg:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *sendMsgView;
@property (weak, nonatomic) IBOutlet UITextView *msgText;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITableView *showMsgTable;
@property (weak, nonatomic) IBOutlet UIImageView *liveUserPic;//主播头像
@property (weak, nonatomic) IBOutlet UILabel *livingShow;//增在直播标识
@property (weak, nonatomic) IBOutlet UILabel *viewerCount;//房间总人数
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutMsgTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutSendMsgViewBottom;
@property (weak,nonatomic) IBOutlet UIButton *btnLove;
@property (weak,nonatomic) IBOutlet UIButton *shareBtn;//分享按钮

@property (weak, nonatomic) IBOutlet UIButton *Goods;//商品按钮


@property (weak, nonatomic) id<ViewControllerReturnDelegate> returnDelegate;
-(IBAction)shareVideo:(UIButton *)sender;

-(IBAction) loveClick;//点击播放爱心动画
-(IBAction)liveUserClick;//头像点击
- (NSString *)getRoomId;
- (IBAction)checkGoods:(id)sender;//点击商品
@end
