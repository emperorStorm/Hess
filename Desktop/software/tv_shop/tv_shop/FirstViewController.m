//
//  FirstViewController.m
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "FirstViewTableViewCell.h"
#import "TVRoom.h"
#import "MJRefresh.h"
#import "MainViewController.h"
#import "LookVideoViewController.h"
#import "LoginViewController.h"
#import "ViewControllerReturnDelegate.h"
#import "XMLReader.h"
#import "AttentionChangeDelegate.h"
#import "LookVideoExitView.h"

#define DEFHIGHT 332 //在iPhone4上直播封面图片的高度
#define ROWHIGHT 342 //默认行高

@interface FirstViewController ()<AddAttentionDelegate, ViewControllerReturnDelegate,AttentionChangeDelegate>{
    NSMutableDictionary *dic;
    NSMutableArray *playDatas;
    NSInteger page;
    NSString *actionUrl;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"homeSel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationController.navigationBarHidden = YES;
    [self.segController.layer setBorderWidth:1.0f];
    [self.segController.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    self.segController.layer.masksToBounds = YES;
    [self.segController.layer setCornerRadius:14.0];
    playDatas = [NSMutableArray array];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    CGFloat liveImgHight = self.view.frame.size.width;
    self.tableView.rowHeight = ROWHIGHT+(liveImgHight-DEFHIGHT);//默认行高加上图片比默认值多出的部分
    UINib *nib = [UINib nibWithNibName:@"FirstViewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:[FirstViewTableViewCell ID]];
    
    page = 0;
    actionUrl = @"GetLiveList";
    [self setupHeader];
    [self setupFooter];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([LocalUser isUserExist]) {
        // 马上进入刷新状态
        if (self.tabBarController.tabBar.tag == 1) {
            [self.tableView.header beginRefreshing];
            self.tabBarController.tabBar.tag = 0;
        }
    }else{
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return playDatas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FirstViewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FirstViewTableViewCell ID] forIndexPath:indexPath];
    cell.viewController = self;
    TVRoom *room = [playDatas objectAtIndex:indexPath.row];
    NSLog(@"id: %@ attention: %@",room.userId, room.isAttetion);
    [cell setValueWithRoom:room];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LookVideoViewController *look = [[LookVideoViewController alloc] init];
    look.room = [playDatas objectAtIndex:indexPath.row];
    look.returnDelegate = self;
    MainViewController *mainView = (MainViewController *)self.tabBarController;
    [mainView updateTabBarHidden:YES];
    [self.navigationController pushViewController:look animated:YES];
}

-(void)returnToLastViewController:(UIViewController *)viewController {
    MainViewController *mainView = (MainViewController *)self.tabBarController;
    [mainView updateTabBarHidden:NO];
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)XMLData
{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:actionUrl forKey:@"action"];
    if ([LocalUser isUserExist]) {
        [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    }
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
//        NSLog(@"返回数据%@", dic);
        [playDatas removeAllObjects];
        for (NSDictionary *temp in [dic objectForKey:@"DataInfos"]) {
            TVRoom *room = [[TVRoom alloc] init];
            [room setValueWithData:temp];
            [playDatas addObject:room];
        }
        [self.tableView.header performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
        [self.tableView reloadData];
        if ([dic[@"Head"][@"Error_Id"] isEqualToString:@"01"]) {
            [self showText:dic[@"Head"][@"Error_Desc"]];
        }
    } failure:self.errorInfo];
}

-(void)addAttention:(NSString *)attentionId{
    if ([LocalUser isUserExist]) {
        // 返回的数据格式是XML
        ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"AddFocus" forKey:@"action"];
        [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
        [dict setObject:attentionId forKey:@"UserId"];
        // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
        [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@",operation);
            // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
            // 第三方库第三方框架,效率低,内存泄漏
             //需要保存一个标识，让关注过的数据不再显示关注按钮
            
            NSXMLParser *parser = (NSXMLParser *)responseObject;
            NSError *error = nil;
            NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//            NSLog(@"%@", xmlDict);
            NSString *isFocus = xmlDict[@"DataInfos"][@"DataInfo"][@"IsFocus"][@"text"];
            if (isFocus ) {
                for (NSInteger i=0; i<playDatas.count; i++) {
                    TVRoom *room = [playDatas objectAtIndex:i];
                    if ([room.userId isEqualToString:attentionId]) {
                        room.isAttetion = isFocus;
//                        break;
//                        NSLog(@"%d =  %@", i, room.isAttetion);
                        
                    }
                    NSLog(@"%d: %@", i, room.isAttetion);
                }
            }
            if([isFocus isEqualToString:@"True"]) {
                
                [self.tableView reloadData];
                [self performSelectorOnMainThread:@selector(showText:) withObject:@"关注成功!" waitUntilDone:NO];
//                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            else if([isFocus isEqualToString:@"False"]){
                [self.tableView reloadData];
                [self performSelectorOnMainThread:@selector(showText:) withObject:@"已取消关注" waitUntilDone:NO];
//                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            
            
        } failure:self.errorInfo];
    }else{
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
    }
}

// 刷新数据代码（开始）
- (void)setupHeader
{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [weakSelf loadNewData];
    }];
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
}

#pragma mark 下拉刷新数据
- (void)loadNewData
{
    // 加载数据
    [self XMLData];
    // 拿到当前的下拉刷新控件，结束刷新状态
//    [self.tableView.header endRefreshing];
}

#pragma mark 上拉刷新
- (void)setupFooter
{
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 忽略掉底部inset
    self.tableView.footer.ignoredScrollViewContentInsetBottom = 0;
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    page++;
    // 1.添加假数据
    [self XMLData];
    // 拿到当前的上拉刷新控件，结束刷新状态
    [self.tableView.footer endRefreshing];
}

// 刷新数据代码（结束）

- (IBAction)selectSegTab:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        actionUrl = @"GetLiveList";
        [self.tableView.header beginRefreshing];
    }else{
        actionUrl = @"GetHotLiveList";
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark 视频播放完毕后关注改变状态（代理）
- (void)AttentionChange:(NSString *)attentionId
{
    [self addAttention:attentionId];
}
@end
