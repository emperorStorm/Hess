//
//  EditHeadPicViewController.m
//  tv_shop
//
//  Created by mac on 15/12/9.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "EditHeadPicViewController.h"
#import "UIView+GetImage.h"

@interface EditHeadPicViewController ()<UIScrollViewDelegate>

@end

@implementation EditHeadPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 0.2;
    [self.headImageView setImage:self.headPic];
    if (self.picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        [self.resetBtn setHidden:YES];
        [self.backIcon setHidden:YES];
    }else{
        [self.resetBtn setHidden:NO];
        [self.backIcon setHidden:NO];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scrollView setContentSize:CGSizeMake(self.headPic.size.width, self.headPic.size.height)];
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.headPic.size.height/2.0, self.headPic.size.width/2.0, 0,0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editFinish:(UIButton *)sender {
    UIImage *imageResult = [self.view screenshotWithRect:self.editArea.frame];
    [self dismissViewControllerAnimated:YES completion:^{
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.picker.view removeFromSuperview];
        [self.picker removeFromParentViewController];
        self.picker = nil;
        [self.getPicDelegate returnImage:imageResult];
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.headImageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [self.scrollView setContentSize:CGSizeMake(self.headPic.size.width, self.headPic.size.height)];
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.headPic.size.height/2.0, self.headPic.size.width/2.0, 0, 0)];
}
- (IBAction)reSelect:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
