//
//  FirstViewTableViewCell.h
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVRoom.h"
#import "UIImageView+WebCache.h"

@protocol AddAttentionDelegate <NSObject>

-(void)addAttention:(NSString *)attentionId;

@end

@interface FirstViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *livePic;
@property (weak, nonatomic) IBOutlet UILabel *roomName;
@property (weak, nonatomic) IBOutlet UIImageView *roomPic;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewerCount;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userHeadPic;
@property (weak, nonatomic) IBOutlet UILabel *liveName;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (retain, nonatomic) NSString *userId;
@property id<AddAttentionDelegate> addDelegete;
@property (weak, nonatomic) TVRoom *room;
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) IBOutlet UILabel *isLiveTag;
@property (weak, nonatomic) IBOutlet UIView *userHeadView;



+(NSString*)ID;
-(void)setValueWithRoom:(TVRoom*)room;
- (IBAction)addAttention:(UIButton *)sender;

@end
