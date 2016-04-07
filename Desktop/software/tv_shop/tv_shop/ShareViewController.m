//
//  ShareViewController.m
//  tv_shop
//
//  Created by mac on 16/1/25.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//

#import "ShareViewController.h"
#import "LookVideoViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//QQ
- (IBAction)qqShare:(UIButton *)sender {
    self.view.hidden = YES;
//    [self shareWithPlatform:UMShareToQQ];
//    if (sender.tag == 1) {
//        [self shareWithPlatform:UMShareToQQ];
//    }else if(sender.tag ==2){
//        [self shareWithPlatform:UMShareToWechatSession];
//    }else{
        [self shareWithPlatform:UMShareToSina];
//    }
}
//微信
- (IBAction)weixinShare:(UIButton *)sender {
    self.view.hidden = YES;
    [self shareWithPlatform:UMShareToWechatSession];
}
//新浪
- (IBAction)sinaShare:(UIButton *)sender {
    self.view.hidden = YES;
    [self shareWithPlatform:UMShareToSina];
}

#pragma mark 各平台分享封装
-(void)shareWithPlatform:(NSString *)type{
    LookVideoViewController *lookV = [[LookVideoViewController alloc]init];
    
    NSString *shareText = [NSString stringWithFormat:@"%@邀您观看现场精彩直播,http://60.190.202.135/wap/N.aspx?c=%@",[LocalUser getName],lookV.room.liveId];
    
    [[UMSocialDataService defaultDataService]
     postSNSWithTypes:@[type]
     content:shareText
     image:nil
     location:nil
     urlResource:nil
     presentedController:self
     completion:^(UMSocialResponseEntity *response){
         if (response.responseCode == UMSResponseCodeSuccess) {
             NSLog(@"分享成功！");
         }
     }
     ];
    lookV.shareReturn = YES;
}

#pragma mark 设置view显示的位置
- (void)shareWithFrame:(UIButton *)shareBtn
{
    CGRect frame = self.view.frame;
    frame.origin.x = shareBtn.frame.origin.x - self.view.frame.size.width/2.0;
    frame.origin.y = shareBtn.frame.origin.y - self.view.frame.size.height;
    frame.size = CGSizeMake(3 * shareBtn.frame.size.width, 6 *shareBtn.frame.size.height);
    self.view.frame = frame;
    self.view.hidden = YES;
}
@end
