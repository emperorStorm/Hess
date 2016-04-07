//
//  SetMyInfoViewController.m
//  tv_shop
//
//  Created by mac on 15/10/25.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "SetMyInfoViewController.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "KGModal.h"
#import "SelectHeadPicViewController.h"
#import "EditHeadPicViewController.h"

@interface SetMyInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CameraDelegate,ReturnHeadPicDelegate>{
    NSMutableDictionary *dic;
    BOOL keyBoardIsHide;
    KGModal *kgModal;
    NSString *currentSex;//当前选中性别
}

@end

@implementation SetMyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.headPic borderColor:nil borderWidth:0 masks:YES cornerRadius:35];
    keyBoardIsHide = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setBoundsWithView:self.manBtn borderColor:[MyColor colorWithHexString:@"F5F5F5" alpha:1.0].CGColor borderWidth:1 masks:YES cornerRadius:8];
    [self setBoundsWithView:self.womenBtn borderColor:[MyColor colorWithHexString:@"F5F5F5" alpha:1.0].CGColor borderWidth:1 masks:YES cornerRadius:8];
    [self getMyInfo];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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

- (void)getMyInfo{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetUserInfo" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        NSLog(@"返回数据%@", dic);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [MyAlertHelper modelWithMsg:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            User *user = [[User alloc] init];
            [user setValueWithData:[[dic objectForKey:@"DataInfos"] objectAtIndex:0]];
            [self setViewValueWithUser:user];
        }
    } failure:self.errorInfo];
}

- (void)setMyInfo{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"SetUserInfo" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    [dict setObject:self.userArea.text forKey:@"userAddress"];
    [dict setObject:self.userMotto.text forKey:@"userSignature"];
    [dict setObject:currentSex forKey:@"userSex"];
    [dict setObject:self.userPhone.text forKey:@"userCellPhone"];
    [dict setObject:self.userEmail.text forKey:@"userEmail"];
    
    // formData是遵守了AFMultipartFormData的对象
    [ApplicationDelegate.manager POST:@"wap/PowerClient.aspx" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 在此位置生成一个要上传的数据体
        // form对应的是html文件中的表单
        if (self.headImage!=nil) {
            UIImage *changeImage = [self imageWithImage:[self fixOrientation:self.headImage] scaledToSize:CGSizeMake(self.view.frame.size.width, (self.view.frame.size.width*self.headImage.size.height)/self.headImage.size.width)];
            NSData *imageData = UIImagePNGRepresentation(changeImage);
            // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
            // 要解决此问题，
            // 可以在上传时使用当前的系统事件作为文件名
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            /*
             此方法参数
             1. 要上传的[二进制数据]
             2. 对应网站上[upload.php中]处理文件的[字段"file"]
             3. 要保存在服务器上的[文件名]
             4. 上传文件的[mimeType]
             */
            [formData appendPartWithFileData:imageData name:@"coverPic" fileName:fileName mimeType:@"image/jpg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"------%@",operation);
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        [self showText:@"保存成功"];
        NSLog(@"返回数据%@", dic);
    } failure:self.errorInfo];
}

-(void)setViewValueWithUser:(User*)user{
    NSURL *url = [NSURL URLWithString:user.userPic];
    [self.headPic sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"icon7@2x.png"]];
    [self.userName setText:user.userName];
    [self.userMotto setText:user.userMotto];
    [self.userArea setText:user.userAddr];
    [self.userPhone setText:user.userPhone];
    [self.userEmail setText:user.userEmail];
    currentSex = user.userSex;
    if ([user.userSex isEqualToString:@"男"]) {
        [self selectMan:nil];
    }else if ([user.userSex isEqualToString:@"女"]){
        [self selectWomen:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)editHeadPic:(UIButton *)sender {
    SelectHeadPicViewController *controller = [[SelectHeadPicViewController alloc] init];
    [controller.view setFrame:CGRectMake(0, 0, 280, controller.view.frame.size.height)];
    controller.camera = self;
    kgModal = [KGModal sharedInstance];
    kgModal.tapOutsideToDismiss = YES;
    kgModal.closeButtonType = KGModalCloseButtonTypeNone;
    [kgModal showWithContentViewController:controller andAnimated:YES];
}

- (IBAction)save:(UIButton *)sender {
    [self.view endEditing:YES];
    if ((![self.userPhone.text isEqualToString:@""]) && (![self isValidateMobile:self.userPhone.text])) {
        [self showText:@"手机号无效"];
    }else if ((![self.userEmail.text isEqualToString:@""]) && (![self isValidateEmail:self.userEmail.text])){
        [self showText:@"邮箱无效"];
    }else{
        [self setMyInfo];
    }
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController.tabBarController.tabBar setHidden:NO];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"*-----HideKeyBoard");
    if (!keyBoardIsHide) {
        keyBoardIsHide = YES;
        NSLog(@"---change");
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height-216)];
    }
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"*-----ShowKeyBoard");
    if (keyBoardIsHide) {
        keyBoardIsHide = NO;
        NSLog(@"----change");
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height+216)];
    }
}

-(void)createCameraWithMode:(NSString *)mode{
    [kgModal hideAnimated:YES withCompletionBlock:^{
        NSLog(@"start takePhoto");
        if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])||([mode isEqualToString:@"Photo"])) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            //设置照相机取景框全屏
            if ([mode isEqualToString:@"Camera"]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                CGSize screenBounds = [UIScreen mainScreen].bounds.size;
                CGFloat cameraAspectRatio = 4.0f/3.0f;
                CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
                CGFloat scale = screenBounds.height / camViewHeight;
                picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
                picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
            }else{
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            [self addChildViewController:picker];
            [self.view addSubview:picker.view];
        }else{
            [self showText:@"对不起,您的设备没有照相功能!"];
        }
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        self.headImage=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.headImage, nil, nil, nil);//保存到相簿
        }
//        [self.headPic setImage:self.headImage];
    }
    EditHeadPicViewController *editPicController = [[EditHeadPicViewController alloc] init];
    editPicController.getPicDelegate = self;
    editPicController.headPic = self.headImage;
    editPicController.picker = picker;
    [picker presentViewController:editPicController animated:YES completion:^{
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
    picker = nil;
    self.headImage = nil;//[self.headPic image];
}

- (IBAction)selectMan:(UIButton *)sender {
    [self.womenBtn setBackgroundColor:[UIColor whiteColor]];
    [self.womenBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.manBtn setBackgroundColor:[MyColor colorWithHexString:@"F75B5F" alpha:1.0]];
    [self.manBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    currentSex = @"男";
}

- (IBAction)selectWomen:(UIButton *)sender {
    [self.manBtn setBackgroundColor:[UIColor whiteColor]];
    [self.manBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.womenBtn setBackgroundColor:[MyColor colorWithHexString:@"F75B5F" alpha:1.0]];
    [self.womenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    currentSex = @"女";
}

-(void)returnImage:(UIImage *)image{
    self.headImage = image;
    [self.headPic setImage:image];
}
@end







