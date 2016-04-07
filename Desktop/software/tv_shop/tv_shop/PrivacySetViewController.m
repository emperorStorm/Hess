//
//  PrivacySetViewController.m
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "PrivacySetViewController.h"
#import "PrivacyTableViewCell.h"

@interface PrivacySetViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *privateDatas;
    NSInteger selectIndex;
    NSMutableDictionary *dic;
}

@end

@implementation PrivacySetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.table.dataSource = self;
    self.table.delegate = self;
    privateDatas = @[@"全公开",@"仅好友可见",@"仅自己能看"];
    self.table.rowHeight = 60;
    selectIndex = [[LocalUser getUserPrivacy] integerValue];
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
    return privateDatas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PrivacyTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"PrivacyTableViewCell" owner:nil options:nil][0];
    [cell.privacyName setText:[privateDatas objectAtIndex:indexPath.row]];
    if (indexPath.row != selectIndex) {
        cell.isSelect.hidden = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectIndex = indexPath.row;
    [self.table reloadData];
}

- (IBAction)back:(UIButton *)sender {
    [self setPrivacyNet];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setPrivacyNet{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"UpdatePrivacy" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:[NSString stringWithFormat:@"%d",selectIndex] forKey:@"type"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/LiveInterface.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        NSLog(@"设置我的隐私返回数据%@", dic);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [self showText:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            [self showText:@"设置成功"];
            [LocalUser setUserPrivacy:[NSString stringWithFormat:@"%d",selectIndex]];
        }
    } failure:self.errorInfo];
}

@end
