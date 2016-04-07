//
//  MyInfoViewController.m
//  tv_shop
//
//  Created by mac on 15/10/19.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyInfoViewController.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "User.h"
#import "MyFansViewController.h"
#import "SetMyInfoViewController.h"
#import "MyVideoViewController.h"
#import "UIImageView+WebCache.h"
#import "MainViewController.h"

#define STARMARGE 2//颜值星的间距
#define STARWIDTH 15//颜值星的宽度


@interface MyInfoViewController (){
    NSMutableDictionary *dic;
    User *userInfo;
}

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    userInfo = [[User alloc] init];
    
    [self setBoundsWithView:self.level borderColor:nil borderWidth:0 masks:YES cornerRadius:6];
    [self setBoundsWithView:self.userPic borderColor:nil borderWidth:0 masks:YES cornerRadius:47];
    
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![LocalUser isUserExist]) {//如果没有登录，则进入登录界面
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
    }else{
        NSLog(@"加载用户数据");
        [self getUserCenterData];
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

//获取用户数据
-(void)getUserCenterData{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetUserCenterInfo" forKey:@"action"];
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
//        NSLog(@"我的主页数据%@", dic);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [self showText:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            [userInfo setValueWithData:[[dic objectForKey:@"DataInfos"] objectAtIndex:0]];
            [LocalUser setUserPrivacy:[[[dic objectForKey:@"DataInfos"] objectAtIndex:0] objectForKey:@"VodPrivacy"]];
//            NSLog(@"隐私类型%@",[LocalUser getUserPrivacy]);
            [self setViewValue];
        }
    } failure:self.errorInfo];
}

-(void)setViewValue{
    self.userName.text = userInfo.userName;
    self.mottoLabel.text = userInfo.userMotto;
    self.fansCount.text = [NSString stringWithFormat:@"%@",userInfo.fansCount];
    self.attetionCount.text = [NSString stringWithFormat:@"%@",userInfo.attetionCount];
    self.level.text = userInfo.userLevel;
    CGRect frameTemp = self.yanzhiControl.frame;
    frameTemp.origin.x = (STARWIDTH+STARMARGE)*([userInfo.yanZhi integerValue]);
    self.yanzhiControl.frame = frameTemp;
    NSURL *url = [NSURL URLWithString:userInfo.userPic];
    [self.userPic sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"icon7@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"头像错误：%@",error);
    }];
}

- (IBAction)editUserInfo:(UIButton *)sender {
//    [self showText:@"正在开发中,敬请期待..."];
    SetMyInfoViewController *setView = [[SetMyInfoViewController alloc] init];
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:setView animated:YES];
}

- (IBAction)myLiveVideo:(UIButton *)sender {
//    [self showText:@"正在开发中,敬请期待..."];
    MyVideoViewController *controller = [[MyVideoViewController alloc] init];
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)myMsg:(UIButton *)sender {
    [self showText:@"正在开发中,敬请期待..."];
}

- (IBAction)setting:(UIButton *)sender {
    SettingViewController *setting = [[SettingViewController alloc] init];
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:setting animated:YES];
}

- (IBAction)showMyAttention:(UIButton *)sender {
    MyFansViewController *fans = [[MyFansViewController alloc] init];
    fans.tag = @"ATTENTION";
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:fans animated:YES];
}

- (IBAction)showMyFans:(UIButton *)sender {
    MyFansViewController *fans = [[MyFansViewController alloc] init];
    fans.tag = @"FANS";
    MainViewController *mainView = (MainViewController *)self.navigationController.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:fans animated:YES];
}
@end
