//
//  MyVideoViewController.h
//  tv_shop
//
//  Created by mac on 15/10/30.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface MyVideoViewController : BasicViewController
- (IBAction)back:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)editor:(UIButton *)sender;//编辑按钮
@property (weak, nonatomic) IBOutlet UIButton *editorTxt;//编辑
- (NSMutableArray *)videosElement;
- (NSMutableArray *)getDeselectCell;
@end
