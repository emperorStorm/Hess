//
//  ShowViewerViewController.m
//  tv_shop
//
//  Created by mac on 15/11/4.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "ShowViewerViewController.h"
#import "UIImageView+WebCache.h"
#import "LookVideoViewController.h"
#define STARMARGE 3//颜值星的间距
#define STARWIDTH 15//颜值星的宽度

@interface ShowViewerViewController ()

@end

@implementation ShowViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.view borderColor:nil borderWidth:0 masks:YES cornerRadius:5];
    [self setBoundsWithView:self.viewerHeadPic borderColor:nil borderWidth:0 masks:YES cornerRadius:45];
    [self setBoundsWithView:self.viewerLevel borderColor:nil borderWidth:0 masks:YES cornerRadius:6];
    
    CGRect frameTemp = self.controlYanzhi.frame;
    frameTemp.origin.x = (STARWIDTH+STARMARGE)*([self.viewer.yanZhi integerValue]);
    self.controlYanzhi.frame = frameTemp;
    
    NSURL *url = [NSURL URLWithString:self.viewer.userPic];
    [self.viewerHeadPic sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"观看者头像加载错误%@",error);
    }];
    
    [self.viewerName setText:self.viewer.userName];
    [self.viewermotto setText:self.viewer.userMotto];
    [self.fansCount setText:self.viewer.fansCount];
    [self.attentionCount setText:self.viewer.attetionCount];
    //判断显示用户的直播数还是主播的直播数
    if ([self.viewer.roomId isEqualToString:[self.control getRoomId]])
    {
        [self.videoCount setText:self.viewer.liveCount];
    }else{
        NSLog(@"%@=====%@",self.viewer.roomId,[self.control getRoomId]);
        [self.videoCount setText:self.viewer.videoCount];
    }
    
    [self.viewerLevel setText:self.viewer.userLevel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
