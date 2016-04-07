//
//  BufferView.m
//  tv_shop
//
//  Created by mac on 15/12/10.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BufferView.h"
#import "TVRoom.h"
#import "UIImageView+WebCache.h"

@implementation BufferView

+ (id) buffer:(NSString *)name imagePath:(NSString *)imagePath
{
    //加载xib获得view
   BufferView *bufferView = [[NSBundle mainBundle] loadNibNamed:@"BufferView" owner:nil options:nil][0];

    //图像设置为圆形
    [bufferView.image.layer setMasksToBounds:YES];
    [bufferView.image.layer setCornerRadius:60];
    [bufferView.image.layer setBorderWidth:4];
    [bufferView.image.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    bufferView.image.contentMode = UIViewContentModeScaleAspectFill;
 
    
    //通过网址获取照片并显示在BufferView上
    NSURL *url = [[NSURL alloc] initWithString:imagePath];
    [bufferView.image sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    //图像下显示的文字
    bufferView.lable.text = [NSString stringWithFormat:@"正在进入%@的直播间，请稍后",name];

    return bufferView;
}
@end
