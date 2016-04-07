//
//  MyFansViewController.m
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyFansViewController.h"
#import "FansTableViewCell.h"
#import "Fans.h"
#import "Attentions.h"
#import "MJRefresh.h"
#import "ShowUserDetailViewController.h"
#import "ChangeStatusDelegate.h"

@interface MyFansViewController ()<UITableViewDelegate,UITableViewDataSource,ChangeStatusDelegate>
{
    NSMutableDictionary *dic;
    NSMutableArray *userDatas;
    NSInteger page;
}

@end

@implementation MyFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 101;
    page = 0;
    userDatas = [NSMutableArray array];
    UINib *nib = [UINib nibWithNibName:@"FansTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:[FansTableViewCell ID]];
    
    [self setupHeader];
    [self setupFooter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"DataShouldUpdate" object:nil];
}

- (void)updateData {
    [self loadNewData];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.tag isEqualToString:@"FANS"]) {
        [self.titleLabel setText:[NSString stringWithFormat:@"我的粉丝(%ld)",userDatas.count]];
    }else if ([self.tag isEqualToString:@"ATTENTION"]){
        [self.titleLabel setText:[NSString stringWithFormat:@"我的关注(%ld)",userDatas.count]];
    }
    return userDatas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FansTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FansTableViewCell ID] forIndexPath:indexPath];
    cell.changeDelegete = self;
    cell.data = [userDatas objectAtIndex:indexPath.row];
    [self setBoundsWithView:cell.attentionBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:cell.headPic borderColor:nil borderWidth:0 masks:YES cornerRadius:40];
    [cell setCellValue:[userDatas objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShowUserDetailViewController *userDetail = [[ShowUserDetailViewController alloc] init];
    userDetail.data = [userDatas objectAtIndex:indexPath.row];
    userDetail.changeDelegete = self;
//    [self.navigationController.navigationBar setHidden:YES];
//    [self.navigationController pushViewController:userDetail animated:YES];
    [userDetail setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:userDetail animated:YES completion:nil];
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController.tabBarController.tabBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)ChangeStatusWithId:(NSString *)attentionId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"AddFocus" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    [dict setObject:attentionId forKey:@"UserId"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:self.errorInfo];
}

- (void)loadData
{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self.tag isEqualToString:@"FANS"]) {
        [dict setObject:@"GetUserFans" forKey:@"action"];
    }else if ([self.tag isEqualToString:@"ATTENTION"]){
        [dict setObject:@"GetUserFocus" forKey:@"action"];
    }
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    [dict setObject:[NSString stringWithFormat:@"%ld",page] forKey:@"PageNo"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        if (page==1) [userDatas removeAllObjects];
        NSMutableArray *temp = [self saveToModel];
        
        if (temp.count==0 && [dic[@"Head"][@"Error_Id"] isEqualToString:@"00"]) {
            page = page-1;
            if ([self.tag isEqualToString:@"FANS"]) {
                [self showText:@"无更多粉丝"];
            }else if ([self.tag isEqualToString:@"ATTENTION"]){
                [self showText:@"无更多关注"];
            }
        }else{
//            if (page==1) [userDatas removeAllObjects];
            [userDatas addObjectsFromArray:temp];
            
            [self.tableView reloadData];
        }
        [self.tableView.header performSelectorOnMainThread:@selector(endRefreshing) withObject:nil waitUntilDone:NO];
    } failure:self.errorInfo];
}

-(NSMutableArray*)saveToModel{
    NSMutableArray *tempDatas = [NSMutableArray array];
//    NSLog(@"返回数据%@", dic);
    for (NSDictionary *temp in [dic objectForKey:@"DataInfos"]) {
        if ([self.tag isEqualToString:@"FANS"]) {
            Fans *fans = [[Fans alloc] init];
            [fans setValueWithData:temp];
            [tempDatas addObject:fans];
        }else if ([self.tag isEqualToString:@"ATTENTION"]){
            Attentions *attention = [[Attentions alloc] init];
            [attention setValueWithData:temp];
            [tempDatas addObject:attention];
        }
    }
    return tempDatas;
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
    [self loadData];
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
    [self loadData];
    // 拿到当前的上拉刷新控件，结束刷新状态
    [self.tableView.footer endRefreshing];
}

// 刷新数据代码（结束）

@end
