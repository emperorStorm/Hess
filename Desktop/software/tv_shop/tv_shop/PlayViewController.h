//
//  PlayViewController.h
//  tv_shop
//
//  Created by mac on 15/10/20.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
//调用闪光灯调用框架
#import <AVFoundation/AVFoundation.h>
#import "TVRoom.h"
@interface PlayViewController : BasicViewController

@property (retain, nonatomic) TVRoom *room;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutMsgTableHeight;
@property (weak,nonatomic) IBOutlet UIButton *btnLove;
@property (retain, nonatomic) UIImagePickerController *playPicker;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITableView *msgView;
- (IBAction)controlPlay:(UIButton *)sender;
- (void)stopLive:(id)sender;
@property (retain, nonatomic) NSString *cid;//直播id
@property (retain, nonatomic) NSString *liveIp;//直播ip
@property (retain, nonatomic) NSString *livePort;//直播端口

@property (nonatomic,retain) AVCaptureSession *captureSesion;//闪光灯
@property (nonatomic,retain) AVCaptureDevice *captureDevice;
@property (weak, nonatomic) IBOutlet UIView *sendMsgView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextView *msgText;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
- (IBAction)controlLight:(UIButton *)sender;
- (IBAction)controlCamera:(UIButton *)sender;
- (IBAction)sendMsg:(UIButton *)sender;
- (IBAction)send:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *viewerNum;
@property (weak, nonatomic) IBOutlet UIImageView *peopleIcon;
- (IBAction)shareVideo:(UIButton *)sender;

@end
