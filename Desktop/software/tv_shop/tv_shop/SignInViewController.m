//
//  SignInViewController.m
//  tv_shop
//
//  Created by mac on 15/10/22.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController (){
    NSMutableDictionary *dic;
}

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.signInfo borderColor:[[MyColor colorWithHexString:@"E1E1E1" alpha:1.0f] CGColor] borderWidth:1 masks:YES cornerRadius:5];
    [self setBoundsWithView:self.signBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.weixinBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
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

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(UIButton *)sender {
    [self showText:@"请登录!"];
    [self back:nil];
}

- (IBAction)getSignCode:(UIButton *)sender {
    NSString *phone = self.phoneNum.text;
    if ([phone isEqualToString:@""]) {
        [MyAlertHelper modelWithMsg:@"请输入手机号!"];
    }else if (![self isValidateMobile: self.phoneNum.text]){
        [MyAlertHelper modelWithMsg:@"手机号无效!"];
    }else{
        [self startTime];
        [self getCodeForPhone:phone];
    };
}
//发送请求获取注册验证码
-(void)getCodeForPhone:(NSString*)phone{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetRegisterValidateCode" forKey:@"action"];
    [dict setObject:phone forKey:@"cellPhone"];
    
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
    } failure:self.errorInfo];
}
//获取验证码倒计时
-(void)startTime{
    __block int timeout=60; //倒计时时间
    [self.getCodeBtn setHidden:YES];
    [self.secRunLabel setHidden:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.getCodeBtn setHidden:NO];
                [self.secRunLabel setHidden:YES];
            });
        }else{
            int seconds = timeout;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [self.secRunLabel setText:[NSString stringWithFormat:@"%@秒后获取",strTime]];
                [UIView commitAnimations];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (IBAction)signIn:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self.phoneNum.text isEqualToString:@""]) {
        [MyAlertHelper modelWithMsg:@"请输入手机号"];
    }else if ([self.signCode.text isEqualToString:@""]){
        [MyAlertHelper modelWithMsg:@"请输入验证码"];
    }else if ([self.userName.text isEqualToString:@""]){
        [MyAlertHelper modelWithMsg:@"请输入用户名"];
    }else if ([self.pwd.text isEqualToString:@""]){
        [MyAlertHelper modelWithMsg:@"请输入密码"];
    }else{
        [self registerUser];
    }
}
//发送请求注册
-(void)registerUser{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Register" forKey:@"action"];
    [dict setObject:self.phoneNum.text forKey:@"loginId"];
    [dict setObject:self.signCode.text forKey:@"code"];
    [dict setObject:self.userName.text forKey:@"userName"];
    [dict setObject:self.pwd.text forKey:@"loginPass"];
    
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
            [self showText:@"注册成功!"];
            [self back:nil];
        }
    } failure:self.errorInfo];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
