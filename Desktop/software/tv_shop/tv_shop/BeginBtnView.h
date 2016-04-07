//
//  BeginBtnView.h
//  tv_shop
//
//  Created by mac on 16/1/21.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyBarButtonItemDelegate <NSObject>
-(void)buttonClick:(UIButton *)sender;
@end
@interface BeginBtnView : UIView

@property (nonatomic,weak) id<MyBarButtonItemDelegate> delegate;
- (IBAction)clickBtn:(UIButton *)sender;
+(BeginBtnView*)createBeginBtnView;

@end
