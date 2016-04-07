//
//  ViewerTableViewCell.m
//  tv_shop
//
//  Created by mac on 15/10/31.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "ViewerTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation ViewerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)ID{
    return @"ViewerCell";
}

-(void)setCellValue:(Viewer *)viewer{
    NSLog(@"-----------%@",viewer.userPic);
    NSURL *url = [NSURL URLWithString:viewer.userPic];
    [self.viewerPic sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"icon7@2x.png"]];
}

@end
