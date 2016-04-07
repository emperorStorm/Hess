//
//  PlayVideoViewController.m
//  tv_shop
//
//  Created by mac on 15/11/11.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "VMediaPlayerDelegate.h"
#import "VMediaPlayer.h"
#import "Vitamio.h"

@interface PlayVideoViewController ()<VMediaPlayerDelegate>{
    NSString *url;
    NSTimer *timer;
}
@property (nonatomic,retain) VMediaPlayer *player;
@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    url = @"";
    [self setBoundsWithView:self.playControlBtn borderColor:[UIColor whiteColor].CGColor borderWidth:1.0 masks:YES cornerRadius:5];
    
    self.sliderControl.value = 0;
    self.sliderControl.middleValue = 0;
    
    [self.sliderControl setThumbImage:YDIMG(@"player-progress-point") forState:UIControlStateNormal];
    [self.sliderControl setThumbImage:YDIMG(@"player-progress-point-h") forState:UIControlStateHighlighted];
    
    [self.sliderControl setMinimumTrackImage:[YDIMG(@"player-progress-h") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4) resizingMode:UIImageResizingModeStretch]];
    [self.sliderControl setMiddleTrackImage:[YDIMG(@"player-progress-loading") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 5, 0) resizingMode:UIImageResizingModeStretch]];
    [self.sliderControl setMaximumTrackImage:YDIMG(@"player-progress")];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showTextDialog:nil];
    [self getVideoUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getVideoUrl{
    // 返回的数据格式是html，但是形式是XML
    ApplicationDelegate.manager.responseSerializer.acceptableContentTypes = [ApplicationDelegate.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [ApplicationDelegate.manager.requestSerializer setValue:@"iphone" forHTTPHeaderField:@"userAgent"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.video.liveId forKey:@"cid"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.video.userId forKey:@"pid"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/GetLiveurl.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            url = [[myParser.parserObjects objectAtIndex:0] objectForKey:@"PlayUrl"];
        }
        [self initPlay];
        [self playVideo];
        NSLog(@"视频链接%@", url);
    } failure:self.errorInfo];
}

-(void)initPlay{
    self.player = [VMediaPlayer sharedInstance];
//    [self.player setupPlayerWithCarrierView:self.container withDelegate:self];
    while(![self.player setupPlayerWithCarrierView:self.container withDelegate:self])
    {
        [self.player reset];
        [self.player unSetupPlayer];
    }
}

-(void)playVideo{
    [self.player setDataSource:[NSURL URLWithString:url] header:nil];
    [self.player prepareAsync];
}

-(void)stopVideo{
    [self.player reset];
    [self.player unSetupPlayer];
}

// 当'播放器准备完成'时, 该协议方法被调用, 我们可以在此调用 [player start]
// 来开始音视频的播放.
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [self.hud removeFromSuperview];
    [self.playControlBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [player start];
    [self startLoop];
}
// 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后
// 操作, 如: 重置播放器, 准备播放下一个音视频等
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [self.playControlBtn setTitle:@"播放" forState:UIControlStateNormal];
    [player pause];
    [player seekTo:0];
    self.sliderControl.value = 1;
    [self stopLoop];
}
// 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参
// 数 arg 包含了错误原因.
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    [self.hud removeFromSuperview];
    [self showText:@"播放失败"];
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
}

-(void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg{
    NSLog(@"缓存进度%@",arg);
    self.sliderControl.middleValue = [arg floatValue]/100.0;
}

-(void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg{
    self.sliderControl.middleValue = 1;
}

-(void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg{
    self.sliderControl.middleValue = 0;
}

- (IBAction)back:(UIButton *)sender {
    [self stopVideo];
    [self stopLoop];
//    [self.navigationController popViewControllerAnimated:YES];
    [self.returnDelegate returnToLastViewController:self];
}
- (IBAction)playControl:(UIButton *)sender {
    if (self.player.isPlaying){
        NSLog(@"视频长度（毫秒）%ld",[self.player getDuration]);
        NSLog(@"当前位置（毫秒）%ld",[self.player getCurrentPosition]);
        [self.playControlBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.player pause];
        [self stopLoop];
    }else{
        [self.playControlBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player start];
        [self startLoop];
    }
}

-(void)updateSlider{
    CGFloat current = [self.player getCurrentPosition];
    CGFloat videoLong = [self.player getDuration];
    self.sliderControl.value = current/videoLong;
}
//开始更改播放进度
-(void)startLoop{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target: self selector: @selector(updateSlider)  userInfo:nil  repeats: YES];
}
//停止更改播放进度
-(void)stopLoop{
    [timer invalidate];
    timer = nil;
}
- (IBAction)valueChange:(YDSlider*)sender {
    CGFloat videoLong = [self.player getDuration];
    [self.player seekTo:videoLong*(sender.value)];
}
@end
