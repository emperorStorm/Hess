//
//  MyVideoTableViewCell.h
//  tv_shop
//
//  Created by mac on 15/10/30.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface MyVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *livePic;
@property (weak, nonatomic) IBOutlet UILabel *liveTime;
@property (weak, nonatomic) IBOutlet UILabel *liveTitle;
@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLeftMarge;
@property (weak, nonatomic) IBOutlet UIButton *remove;
@property (weak, nonatomic) id control;
@property (assign, nonatomic) int index;  //cell在整个数组中的下标

+(NSString*)ID;
-(void)setCellValue:(Video*)video;
- (void)framerRight;
- (void)frameLeft;
- (IBAction)removeChange:(id)sender; //圆点按钮
@end
