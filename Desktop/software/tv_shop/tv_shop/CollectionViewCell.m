//
//  CollectionViewCell.m
//  tv_shop
//
//  Created by oyoung on 15/12/1.
//  Copyright © 2015年 peraytech. All rights reserved.
//

#import "CollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)init {
    self = [super init];
    if (self) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CollectionViewCell" owner:self options:nil];
        if (views.count < 1) {
            return nil;
        }
        if (![views[0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = views[0];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CollectionViewCell" owner:self options:nil];
        if (views.count < 1) {
            return nil;
        }
        if (![views[0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = views[0];
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}

-(void)setImageWithURL:(NSURL *)url
{
    [self.imageLiveView sd_setImageWithURL:url placeholderImage:nil];
}

+(NSString *)ID
{
    return @"CollectionViewCell";
}

@end
