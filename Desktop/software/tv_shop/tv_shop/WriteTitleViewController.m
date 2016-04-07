//
//  WriteTitleViewController.m
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "WriteTitleViewController.h"
#import "PlayViewController.h"
#import "ParserCreateLiveData.h"
#import "MainViewController.h"

@interface WriteTitleViewController ()<UITextFieldDelegate>{
    NSMutableDictionary *dic;
    NSArray *data;
    BOOL livePublic;
}

@end

@implementation WriteTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [self.imageView setImage:self.image];
    
    self.textField.delegate = self;
    //设置输入款placeholder字体颜色
    [self.textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    //设置开始直播按钮边框
    [self setBoundsWithView:self.beginPlay borderColor:[[MyColor colorWithHexString:@"f75b57" alpha:1.0] CGColor] borderWidth:2 masks:YES cornerRadius:25];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reset:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 隐藏键盘
//点击屏幕隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
//点击键盘的return键隐藏键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)beginPlay:(UIButton *)sender {
    NSLog(@"开始直播");
//    if ([self.textField.text isEqualToString:@""]) {
//        [self showText:@"请输入直播标题"];
//    }else{
        [self showTextDialog:@"正在连接..."];
        [self createLive];
//    }
}

-(void)createLive{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *session = [[LocalUser getSession] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *videoName = @"直播";
    if (![self.textField.text isEqualToString:@""]) {
        videoName = self.textField.text;
    }
    NSString *share = [NSString stringWithFormat:@"%d", livePublic ? 1 : 0];
    [dict setObject:session forKey:@"userToken"];
    [dict setObject:share forKey:@"share"];
    [dict setObject:videoName forKey:@"videoName"];
    [dict setObject:@"" forKey:@"videoDesc"];
    [dict setObject:@"" forKey:@"phones"];
    [dict setObject:[LocalUser getRoomId] forKey:@"spaceId"];
    [dict setObject:@"0" forKey:@"expectTime"];
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",SERVER_URL,@"wap/LiveCreate.aspx"];
    __block NSURL *url = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:dict].URL;
    ParserCreateLiveData *myParser = [[ParserCreateLiveData alloc] init];
    data = [myParser parserData:url];
    if ([[data objectAtIndex:0] isEqualToString:@"0"]) {
        PlayViewController *play = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
        NSString *str = [data objectAtIndex:1];
        NSArray *liveArr = [str componentsSeparatedByString:@"/"];
        NSArray *ipAndPort = [[liveArr objectAtIndex:2] componentsSeparatedByString:@":"];
        NSString *cid = [liveArr lastObject];
        
        play.cid = cid;
        play.liveIp = [ipAndPort objectAtIndex:0];
        play.livePort = [ipAndPort objectAtIndex:1];
        
        NSLog(@"直播id%@",play.cid);
        NSLog(@"直播ip和port%@   %@",play.liveIp,play.livePort);
        
        [self.navigationController pushViewController:play animated:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
//        [self postUploadImage];
    }
}

- (IBAction)cancel:(UIButton *)sender {
    NSLog(@"取消编辑直播标题");
    MainViewController *tabBarController = (MainViewController *)self.tabBarController;
    [tabBarController setSelectedIndex:0];
    [tabBarController updateTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark - 截取图片
- (UIImage*)cutImageWithSize:(CGRect)frame;
{
    CGFloat count = self.image.size.width/frame.size.width;
    CGRect rect = CGRectMake(frame.origin.x*count, frame.origin.y*count, frame.size.width*count, frame.size.height*count);//创建矩形框
    CGImageRef ref = CGImageCreateWithImageInRect([self.image CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
//    UIImage * image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([self.image CGImage], rect)];
    return image;
}

#pragma mark - POST上传
- (void)postUploadImage
{
//    __block UIImage *image = [self cutImageWithSize:self.selectTool.frame];
//    NSLog(@"截取的图片 %@",image);
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"UploadLiveCover" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"k"];
    NSString *str = [data objectAtIndex:1];
    NSString *cid = [[str componentsSeparatedByString:@"/"] lastObject];
    [dict setObject:cid forKey:@"cid"];
    
    // formData是遵守了AFMultipartFormData的对象
    [ApplicationDelegate.manager POST:@"wap/LiveInterface.aspx" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 在此位置生成一个要上传的数据体
        // form对应的是html文件中的表单
        NSData *imageData = UIImagePNGRepresentation(self.image);
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
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"------%@",operation);
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        NSLog(@"返回数据%@", dic);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"错误 %@", error.localizedDescription);
    }];
}

- (IBAction)selectPrivate:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"全公开"]) {
        [self.unPrivateBtn setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        livePublic = YES;
    }else{
        [self.privateBtn setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        livePublic = NO;
    }
    [sender setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
}
@end
