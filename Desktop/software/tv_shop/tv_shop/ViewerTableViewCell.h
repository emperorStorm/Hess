//
//  ViewerTableViewCell.h
//  tv_shop
//
//  Created by mac on 15/10/31.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Viewer.h"

@interface ViewerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *viewerPic;
+(NSString*)ID;
-(void)setCellValue:(Viewer*)viewer;

@end
