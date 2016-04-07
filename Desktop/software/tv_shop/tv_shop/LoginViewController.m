//
//  LoginViewController.m
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "LoginViewController.h"
#import "SignInViewController.h"
#import "MainViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "XMLReader.h"
#import "ForgetPwdViewController.h"

@interface LoginViewController ()<TencentSessionDelegate>
{
    NSMutableDictionary *dic;
    TencentOAuth *tencentOAuth;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self setBoundsWithView:self.loginInfo borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.loginBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.weixinBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.weixin borderColor:nil borderWidth:0 masks:YES cornerRadius:self.weixin.frame.size.width/2];
    [self setBoundsWithView:self.sina borderColor:nil borderWidth:0 masks:YES cornerRadius:self.sina.frame.size.width/2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signIn:(UIButton *)sender {
    SignInViewController *signIn = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    [self.navigationController pushViewController:signIn animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)login:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self.phoneNum.text isEqualToString:@""]) {
        [MyAlertHelper modelWithMsg:@"请输入手机号"];
    }else{
        // 返回的数据格式是XML
        ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"Login" forKey:@"action"];
        [dict setObject:self.phoneNum.text forKey:@"loginId"];
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
                NSLog(@"保存用户数据");
                [LocalUser setUserInfo:[[dic objectForKey:@"DataInfos"] objectAtIndex:0]];
                [self showText:@"登录成功!"];
                [self.tabBarController.tabBar setHidden:NO];
                [self.tabBarController.tabBar setTag:1];//用来判断返回回去是否要刷新页面，如果返回的是首页
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:self.errorInfo];
    }
}

#pragma mark 微信第三方登录
- (IBAction)weixinLogin:(UIButton *)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    //授权登录
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            NSLog(@"++++++++++++++username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            //得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                NSLog(@"SnsInformation is=========== %@",response.data);
                //获取微信第三方用户登录信息
                NSString *weixinName =[response.data objectForKey:@"screen_name"];
                NSString *gender =[response.data objectForKey:@"gender"];
                NSString *iconURL =[response.data objectForKey:@"profile_image_url"];
                NSString *address =[response.data objectForKey:@"location"];
                NSString *openid =[response.data objectForKey:@"openid"];
                
                // 返回的数据格式是XML
                ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"RegisterForWebChat" forKey:@"action"];
                [dict setObject:openid forKey:@"loginId"];
                [dict setObject:weixinName forKey:@"userName"];
                [dict setObject:gender forKey:@"userSex"];
                [dict setObject:iconURL forKey:@"userHeadUrl"];
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"registerType"];
                [dict setObject:address forKey:@"userAddress"];
                
                //网络请求
                [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //解析返回的内容->字典
                    NSXMLParser *parser = (NSXMLParser *)responseObject;
                    NSError *error = nil;
                    NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
                    NSLog(@"=====xmlDict：%@",xmlDict);
                    [self addlogin:openid];
                    
                    [self showText:@"登录成功!"];
//                    [self.tabBarController.tabBar setHidden:NO];
                    MainViewController *mainView = (MainViewController *)self.tabBarController;
                    [mainView updateTabBarHidden:NO];
                    [self.tabBarController.tabBar setTag:1];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:self.errorInfo];
            }];
        }
    });
    
    
}

#pragma mark 新浪第三方登录
- (IBAction)sinaLogin:(id)sender
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            NSLog(@"username is %@, uid is %@, token is %@ url is ++++++++%@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            //获取accestoken以及新浪用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                NSLog(@"SnsInformation is====== %@",response.data);
                //获取新浪第三方用户登录信息
                NSString *sinaName =[response.data objectForKey:@"screen_name"];
                NSString *sinaGender =[response.data objectForKey:@"gender"];
                NSString *sinaIconURL =[response.data objectForKey:@"profile_image_url"];
                NSString *sianAddress =[response.data objectForKey:@"location"];
                NSString *accesstoken=[response.data objectForKey:@"access_token"];
                //注册
                ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"RegisterForWebChat" forKey:@"action"];
                [dict setObject:accesstoken forKey:@"loginId"];
                [dict setObject:sinaName forKey:@"userName"];
                [dict setObject:sinaGender forKey:@"userSex"];
                [dict setObject:sinaIconURL forKey:@"userHeadUrl"];
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"registerType"];
                [dict setObject:sianAddress forKey:@"userAddress"];
                
                //网络请求
                [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //解析返回的内容->字典
                    NSXMLParser *parser = (NSXMLParser *)responseObject;
                    NSError *error = nil;
                    NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
                    NSLog(@"=====xmlDict：%@",xmlDict);
                    [self addlogin:accesstoken];
                    
                    [self showText:@"登录成功!"];
//                    [self.tabBarController.tabBar setHidden:NO];
                    MainViewController *mainView = (MainViewController *)self.tabBarController;
                    [mainView updateTabBarHidden:NO];
                    [self.tabBarController.tabBar setTag:1];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:self.errorInfo];
            }];
        }});

}

#pragma mark 忘记密码
- (IBAction)forgetPwd:(UIButton *)sender {
    ForgetPwdViewController *forget = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
    [self.navigationController pushViewController:forget animated:YES];
}

#pragma mark QQ第三方登录
-(IBAction)qqLogin:(id)sender
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            NSLog(@"username is %@, uid is %@, token is %@ url is ++++++++%@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                NSLog(@"SnsInformation is====== %@",response.data);
                
                //获取QQ第三方用户登录信息
                NSString *qqName =[response.data objectForKey:@"screen_name"];
                NSString *qqGender =[response.data objectForKey:@"gender"];
                NSString *qqIconURL =[response.data objectForKey:@"profile_image_url"];
//                NSString *qqAddress =[response.data objectForKey:@"location"];
                NSString *accesstoken=[response.data objectForKey:@"access_token"];
                //注册
                ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"RegisterForWebChat" forKey:@"action"];
                [dict setObject:accesstoken forKey:@"loginId"];
                [dict setObject:qqName forKey:@"userName"];
                [dict setObject:qqGender forKey:@"userSex"];
                [dict setObject:qqIconURL forKey:@"userHeadUrl"];
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"registerType"];
//                [dict setObject:qqAddress forKey:@"userAddress"];
                
                //网络请求
                [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //解析返回的内容->字典
                    NSXMLParser *parser = (NSXMLParser *)responseObject;
                    NSError *error = nil;
                    NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
                    NSLog(@"=====xmlDict：%@",xmlDict);
                    [self addlogin:accesstoken];
                    
                    [self showText:@"登录成功!"];
                    //                    [self.tabBarController.tabBar setHidden:NO];
                    MainViewController *mainView = (MainViewController *)self.tabBarController;
                    [mainView updateTabBarHidden:NO];
                    [self.tabBarController.tabBar setTag:1];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:self.errorInfo];
            }];
        }});
    

//    tencentOAuth=[[TencentOAuth alloc]initWithAppId:@"1105009253" andDelegate:self];
//    
//    NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
//    //登录授权
//    [tencentOAuth authorize:permissions inSafari:NO];
//    NSLog(@"已授权信息:%@",permissions);
}

//QQ获取用户个人信息回调
//-(void)getUserInfoResponse:(APIResponse *)response
//{
//    NSLog(@"===========respons:%@",response.jsonResponse);
//    
//    //获取qq第三方的用户信息
//    NSString *qqname =[response.jsonResponse objectForKey:@"nickname"];
//    NSString *gender =[response.jsonResponse objectForKey:@"gender"];
//    NSString *imageString = [NSString stringWithFormat:@"%@",[response.jsonResponse objectForKey:@"figureurl_qq_2"]];
//    NSURL *url = [[NSURL alloc] initWithString:imageString];
//    NSString *address =[response.jsonResponse objectForKey:@"city"];
//
//    // 注册
//    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:@"RegisterForWebChat" forKey:@"action"];
//    [dict setObject:tencentOAuth.openId forKey:@"loginId"];
//    [dict setObject:qqname forKey:@"userName"];
//    [dict setObject:gender forKey:@"userSex"];
//    [dict setObject:url forKey:@"userHeadUrl"];
//    [dict setObject:[NSNumber numberWithInt:2] forKey:@"registerType"];
//    [dict setObject:address forKey:@"userAddress"];
//    
//    //网络请求
//    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //解析返回的内容->字典
//        NSXMLParser *parser = (NSXMLParser *)responseObject;
//        NSError *error = nil;
//        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//        NSLog(@"=====xmlDict：%@",xmlDict);
//        [self addlogin:tencentOAuth.openId];
//        
//        [self showText:@"登录成功!"];
////        [self.tabBarController.tabBar setHidden:NO];
//        MainViewController *mainView = (MainViewController *)self.tabBarController;
//        [mainView updateTabBarHidden:NO];
//        [self.tabBarController.tabBar setTag:1];
//        [self.navigationController popViewControllerAnimated:YES];
//    } failure:self.errorInfo];
//}


//QQ登录成功后的回调
//- (void)tencentDidLogin
//{
//        if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length])
//    {
//        //  记录登录用户的OpenID、Token以及过期时间
//        [tencentOAuth getUserInfo];
//        NSLog(@"已获取个人信息,接口凭证为：%@",tencentOAuth.accessToken);
//        NSLog(@"已获取个人信息,接口凭证为：%@",tencentOAuth.openId);
//    }
// 
//}

#pragma mark 登录
- (void)addlogin:(NSString *)account
{
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *diction = [[NSMutableDictionary alloc] init];
    [diction setObject:@"Login" forKey:@"action"];
    [diction setObject:account forKey:@"loginId"];
    [diction setObject:account forKey:@"loginPass"];
    
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:diction success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict1 = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
        
        NSLog(@"保存用户数据");
        [LocalUser setThree:[[xmlDict1 objectForKey:@"DataInfos"] objectForKey:@"DataInfo"]];
    } failure:self.errorInfo];
}

@end
