//
//  MyFansViewController.h
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface MyFansViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) NSString *tag;
- (IBAction)back:(UIButton *)sender;

@end
