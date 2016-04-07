//
//  ForgetPwdViewController.m
//  tv_shop
//
//  Created by mac on 16/1/11.
//  Copyright (c) 2016年 peraytech. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "XMLReader.h"

@interface ForgetPwdViewController ()

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 返回按钮
- (IBAction)back:(UIButton *)sender {
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击获取验证码
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

#pragma mark 获取验证码倒计时
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

#pragma mark 发送请求获取注册验证码
-(void)getCodeForPhone:(NSString*)phone{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetForgotPasswordValidateCode" forKey:@"action"];
    [dict setObject:phone forKey:@"cellPhone"];
    
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        //解析返回的内容->字典
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//        NSLog(@"=====xmlDict：%@",xmlDict);
    } failure:self.errorInfo];
}

#pragma mark 确认按钮
- (IBAction)signIn:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self.phoneNum.text isEqualToString:@""]) {
        [MyAlertHelper modelWithMsg:@"请输入手机号"];
    }else if ([self.signCode.text isEqualToString:@""]){
        [MyAlertHelper modelWithMsg:@"请输入验证码"];
    }else if ([self.newpwd.text isEqualToString:@""]){
        [MyAlertHelper modelWithMsg:@"请输入新的密码"];
    }else if(![self.confirmpwd.text isEqual:self.newpwd.text]){
        [MyAlertHelper modelWithMsg:@"密码不一致"];
    }else{
        [self change];
    }
}

#pragma mark 发送修改密码请求
-(void)change{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"ChangePassWord" forKey:@"action"];
    [dict setObject:self.phoneNum.text forKey:@"loginId"];
    [dict setObject:self.confirmpwd.text forKey:@"loginPass"];
    [dict setObject:self.signCode.text forKey:@"code"];
    
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        //解析返回的内容->字典
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//        NSLog(@"=====xmlDict：%@",xmlDict);
        if (![[[[[xmlDict objectForKey:@"DataInfos"]objectForKey:@"Head"] objectForKey:@"Error_Id"]objectForKey:@"text"] isEqualToString:@"00"]) {
            [MyAlertHelper modelWithMsg:[[[[xmlDict objectForKey:@"DataInfos"]objectForKey:@"Head"] objectForKey:@"Error_Desc"]objectForKey:@"text"]];
        }else{
            [self showText:@"修改成功!"];
            [self back:nil];
        }
    } failure:self.errorInfo];
}
@end
