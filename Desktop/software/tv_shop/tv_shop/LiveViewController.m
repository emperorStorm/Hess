//
//  LiveViewController.m
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "LiveViewController.h"
#import "WriteTitleViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"

@interface LiveViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.photograph borderColor:[[UIColor whiteColor] CGColor] borderWidth:2 masks:YES cornerRadius:25];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    if (![LocalUser isUserExist]) {//如果没有登录，则进入登录界面
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
    }else{
        if (self.picker==nil) {
            [self createCameraView];
        }else{
            [self.view insertSubview:self.picker.view belowSubview:self.backImage];
//            [self.view insertSubview:self.picker.view atIndex:0];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.picker removeFromParentViewController];
    [self.picker.view removeFromSuperview];
    self.picker = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//创建照相机
-(void)createCameraView{
    NSLog(@"start takePhoto");
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *homeController = (MainViewController*)[board instantiateViewControllerWithIdentifier:@"Main"];
        [ApplicationDelegate.window setRootViewController:homeController];
        [self showText:@"对不起,您的设备没有照相功能!"];
    }else{
        self.picker = [[UIImagePickerController alloc]init];
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.delegate = self;
        self.picker.allowsEditing = NO;
        self.picker.showsCameraControls = NO;
        //设置照相机取景框全屏
        CGSize screenBounds = [UIScreen mainScreen].bounds.size;
        CGFloat cameraAspectRatio = 4.0f/3.0f;
        CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
        CGFloat scale = screenBounds.height / camViewHeight;
        self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
        self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, scale, scale);

        [self addChildViewController:self.picker];
        [self.view insertSubview:self.picker.view atIndex:0];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)back:(UIButton *)sender {
    [self.tabBarController setSelectedIndex:0];
    [self.tabBarController.tabBar setHidden:NO];
}

- (IBAction)changeCameraDevice:(UIButton *)sender {
    if (self.picker.cameraDevice ==UIImagePickerControllerCameraDeviceRear ) {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    [self animationWithView:self.view WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
}

- (IBAction)takePhoto:(UIButton *)sender {
    [self.picker takePicture];
}

- (IBAction)selectPhoto:(UIButton *)sender {
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.view bringSubviewToFront:self.picker.view];
}

- (IBAction)cancelTakePhone:(UIButton *)sender {
    [self back:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    WriteTitleViewController *controller = [[WriteTitleViewController alloc] initWithNibName:@"WriteTitleViewController" bundle:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        UIImage *changeImage = [self imageWithImage:[self fixOrientation:image] scaledToSize:CGSizeMake(self.view.frame.size.width, (self.view.frame.size.width*image.size.height)/image.size.width)];
        UIImage *newImage = [self cutImageWithSize:self.selectTool.frame image:[self fixOrientation:changeImage]];
        controller.image = newImage;
        if (self.picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        }
    }
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 截取图片
- (UIImage*)cutImageWithSize:(CGRect)frame image:(UIImage*)image;
{
    CGFloat yValue = (self.view.frame.size.height-image.size.height)/2;
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y-yValue, frame.size.width, frame.size.height);//创建矩形框
//    UIImage * newImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], rect)];
    CGImageRef ref = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return newImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [self.view sendSubviewToBack:picker.view];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self back:nil];
}

@end
