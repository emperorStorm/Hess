//
//  CollectionViewCell.h
//  tv_shop
//
//  Created by oyoung on 15/12/1.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageLiveView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (NSString *)ID;

-(void)setTitle:(NSString *)title;
-(void)setImageWithURL:(NSURL *)imageUrl;

@end
