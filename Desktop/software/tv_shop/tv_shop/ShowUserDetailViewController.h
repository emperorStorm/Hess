//
//  ShowUserDetailViewController.h
//  tv_shop
//
//  Created by mac on 15/11/5.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"
#import "Fans.h"
#import "Attentions.h"
#import "ChangeStatusDelegate.h"

@interface ShowUserDetailViewController : BasicViewController<UICollectionViewDataSource, UICollectionViewDelegate>
- (IBAction)back:(UIButton *)sender;
@property (nonatomic,retain) id data;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLevel;
@property (weak, nonatomic) IBOutlet UILabel *userMotto;
@property (weak, nonatomic) IBOutlet UILabel *attetionCount;
@property (weak, nonatomic) IBOutlet UILabel *fansCount;
@property (weak, nonatomic) IBOutlet UILabel *videoCount;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIButton *attentionStatusButton;

@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewConstraintHeight;
@property (weak, nonatomic) IBOutlet UIView *starsView;
@property (weak, nonatomic) IBOutlet UIView *faceLevelView;

@property id<ChangeStatusDelegate> changeDelegete;

@end
