//
//  ViewController.m
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MainViewController.h"
#import "UIView+ConstraintHelper.h"

@interface MainViewController ()
@property (strong, nonatomic) BeginBtnView *centerView;
@property (weak, nonatomic) UIButton *liveButton;

@end

@implementation MainViewController
@synthesize centerView;
@synthesize liveButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //设置tabBarItem选中时的颜色
    self.tabBar.selectedImageTintColor = [MyColor colorWithHexString:@"f75b5f" alpha:1.0f];
    centerView = [BeginBtnView createBeginBtnView];
    CGRect screnBounts = [ UIScreen mainScreen ].bounds;
    [centerView setFrame:CGRectMake((screnBounts.size.width-centerView.frame.size.width)/2, screnBounts.size.height-centerView.frame.size.height, centerView.frame.size.width, centerView.frame.size.height)];
    
    centerView.delegate = self;
    [self.view addSubview:centerView];
}

//-(void)setupCenterButtonWithImage:(UIImage *)image selectImage:(UIImage *)selectImage {
//    centerView = [[UIView alloc] init];
//    //按钮
//    liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    liveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
//    | UIViewAutoresizingFlexibleLeftMargin
//    | UIViewAutoresizingFlexibleBottomMargin
//    | UIViewAutoresizingFlexibleTopMargin;
//    liveButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
//    [liveButton setImage:image forState:UIControlStateNormal];
//    [liveButton setImage:selectImage forState:UIControlStateSelected];
//    liveButton.adjustsImageWhenHighlighted = NO;
//    [liveButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [liveButton.layer setAffineTransform:CGAffineTransformMakeScale(1.3, 1.3)];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 40)];
//    
//    [label setText:@"直播"];
//    label.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
//    centerView.frame = CGRectMake(0, 0, self.tabBar.frame.size.height + 10, self.tabBar.frame.size.height + 10);
//    centerView.backgroundColor = [MyColor colorWithHexString:@"f75b5f" alpha:1.0];
//    centerView.layer.cornerRadius = centerView.frame.size.width / 2;
//    CGFloat heightDiff = centerView.frame.size.height - self.tabBar.frame.size.height;
//    CGPoint center = self.tabBar.center;
//    center.y -= heightDiff / 2;
//    centerView.center = center;
//    
//    center = [UIView CGRectGetCenter:centerView.bounds];
//    center.y -= liveButton.frame.size.height / 4;
//    liveButton.center = center;
//    center = [UIView CGRectGetCenter:centerView.bounds];
//    center.y += label.frame.size.height / 2;
//    label.center = center;
//    
//    [centerView addSubview:liveButton];
//    [centerView addSubview:label];
//    
//    [self.view addSubview:centerView];
//    
//}

-(void)updateTabBarHidden:(BOOL)hidden {
    self.tabBar.hidden = hidden;
    centerView.hidden = hidden;
}



-(void)buttonClick:(UIButton *)sender {
    self.selectedIndex = 1;
    centerView.hidden = YES;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if(self.selectedIndex == 2) {
        liveButton.selected = YES;
    }
    else {
        liveButton.selected = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

@end
