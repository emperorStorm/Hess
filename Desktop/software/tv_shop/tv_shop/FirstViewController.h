//
//  FirstViewController.h
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "BasicViewController.h"

@interface FirstViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)selectSegTab:(UISegmentedControl *)sender;

@end
