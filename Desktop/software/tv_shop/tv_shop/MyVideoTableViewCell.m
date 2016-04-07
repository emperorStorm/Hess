//
//  MyVideoTableViewCell.m
//  tv_shop
//
//  Created by mac on 15/10/30.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyVideoTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MyVideoViewController.h"
#import "Video.h"
@implementation MyVideoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)ID{
    return @"MyVideoCell";
}

-(void)setCellValue:(Video *)video{
    NSURL *url = [NSURL URLWithString:video.livePic];
    [self.livePic sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"直播封面加载错误 %@",error);
    }];
    [self.liveTitle setText:video.liveTitle];
    [self.liveTime setText:video.liveTime];
    if ([video.isRed isEqualToString:@"0"]) {
        self.remove.backgroundColor =[UIColor whiteColor];
    }else{
        self.remove.backgroundColor =[UIColor redColor];
    }
}

#pragma mark 向右偏移
- (void)framerRight
{
    [self.imageLeftMarge setConstant:58];
    self.remove.layer.cornerRadius = 12.5;
    self.remove.layer.borderColor = [[UIColor grayColor] CGColor];
    self.remove.layer.borderWidth = 1;
    self.remove.hidden = NO;
}

#pragma mark 向左偏移
- (void)frameLeft
{
    [self.imageLeftMarge setConstant:8];
    self.remove.hidden = YES;
}

#pragma mark 点击被选变色
- (IBAction)removeChange:(id)sender
{
    Video *video = [self.control videosElement][self.index];
    //变色
    if (self.remove.backgroundColor ==[UIColor whiteColor]) {
        self.remove.backgroundColor = [UIColor redColor];
        video.isRed = @"1";
        [[self.control getDeselectCell] addObject:video];
    }else{
        self.remove.backgroundColor = [UIColor whiteColor];
        video.isRed = @"0";
        [[self.control getDeselectCell] removeObject:video];
    }
}
@end
