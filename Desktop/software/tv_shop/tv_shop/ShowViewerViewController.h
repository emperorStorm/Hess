//
//  ShowViewerViewController.h
//  tv_shop
//
//  Created by mac on 15/11/4.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "Viewer.h"

@interface ShowViewerViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *viewerHeadPic;
@property (weak, nonatomic) IBOutlet UILabel *viewerName;
@property (weak, nonatomic) IBOutlet UILabel *viewermotto;
@property (weak, nonatomic) IBOutlet UIView *controlYanzhi;
@property (weak, nonatomic) IBOutlet UILabel *attentionCount;
@property (weak, nonatomic) IBOutlet UILabel *fansCount;
@property (weak, nonatomic) IBOutlet UILabel *videoCount;
@property (retain, nonatomic) Viewer *viewer;
@property (weak, nonatomic) IBOutlet UILabel *viewerLevel;

@property (weak, nonatomic) id control;
@end
