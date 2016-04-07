//
//  MyVideoViewController.m
//  tv_shop
//
//  Created by mac on 15/10/30.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "MyVideoViewController.h"
#import "MyVideoTableViewCell.h"
#import "Video.h"
#import "PlayVideoViewController.h"
#import "ViewControllerReturnDelegate.h"
#import "XMLReader.h"

@interface MyVideoViewController ()<UITableViewDataSource,UITableViewDelegate, ViewControllerReturnDelegate>
{
    NSMutableArray *videos;
    NSMutableDictionary *dic;
    UIView *upward;
    NSMutableArray *_deselectCell;
}

@end

@implementation MyVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 116;
    UINib *nib = [UINib nibWithNibName:@"MyVideoTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:[MyVideoTableViewCell ID]];
    
    videos = [NSMutableArray array];
    [self loadData];
    
    //创建删除弹框
    CGRect screenBounds = [[UIScreen mainScreen] bounds];//屏幕尺寸
    upward = [[UIView alloc]initWithFrame:CGRectMake(0, screenBounds.size.height, screenBounds.size.width, 60)];
    upward.backgroundColor = [UIColor whiteColor];
    UIButton *all = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width/2, 60)];
    [all setTitle:@"全选" forState:UIControlStateNormal];
    [all setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [all addTarget:self action:@selector(allchoose) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *del = [[UIButton alloc]initWithFrame:CGRectMake(screenBounds.size.width/2, 0, screenBounds.size.width/2, 60)];
    [del setTitle:@"删除" forState:UIControlStateNormal];
    [del setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [del addTarget:self action:@selector(anyDelete) forControlEvents:UIControlEventTouchUpInside];
    
    [upward addSubview:all];
    [upward addSubview:del];
    [self.view addSubview:upward];
    
    _deselectCell = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (videos.count == 0) {
        self.editorTxt.hidden = YES;
    }else{
        self.editorTxt.hidden = NO;
    }
    return videos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyVideoTableViewCell ID] forIndexPath:indexPath];
    [cell setCellValue:[videos objectAtIndex:indexPath.row]];
    cell.control = self;
    //编辑或者完成状态
    if (self.editorTxt.tag==1) {
        [cell framerRight];
        NSLog(@"%f",cell.ContentView.frame.origin.x);
    }else{
        [cell frameLeft];
    }
    cell.index = indexPath.row;
    cell.tag = indexPath.row;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //编辑状态里不可点击
    if ([self.editorTxt.titleLabel.text isEqualToString:@"编辑"]) {
        PlayVideoViewController *playVideo = [[PlayVideoViewController alloc] init];
        playVideo.video = [videos objectAtIndex:indexPath.row];
        playVideo.returnDelegate = self;
        [self.navigationController pushViewController:playVideo animated:YES];
    }
}

-(void)loadData{
    // 返回的数据格式是html，但是形式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"GetLiveVideoList" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    
    [videos removeAllObjects];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
        [videos addObjectsFromArray:[Video saveToModelWithArr:[dic objectForKey:@"DataInfos"]]];
        if (videos.count==0) {
            [self showText:@"您还没有直播视频"];
        }
        
        [self.tableView reloadData];
        [self.titleLabel setText:[NSString stringWithFormat:@"我的直播(%d)",videos.count]];
        NSLog(@"我的直播列表%@", dic);
    } failure:self.errorInfo];
}

- (IBAction)back:(UIButton *)sender {
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)returnToLastViewController:(UIViewController *)viewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击编辑按钮
- (IBAction)editor:(UIButton *)sender{
    //编辑或者完成状态
    if ([self.editorTxt.titleLabel.text isEqualToString:@"编辑"]) {
        [self.editorTxt setTag:1];
        [self.editorTxt setTitle:@"完成" forState:UIControlStateNormal];
    }else{
        [self.editorTxt setTag:0];
        [self.editorTxt setTitle:@"编辑" forState:UIControlStateNormal];
    }
    
    //动画
    [UIView animateWithDuration:1.0 animations:^{
        //弹出全选和删除框
        if (self.editorTxt.tag==1) {
            CGRect frame = upward.frame;
            frame.origin.y -=upward.frame.size.height;
            upward.frame = frame;
        }else{
            CGRect frame = upward.frame;
            frame.origin.y +=upward.frame.size.height;
            upward.frame = frame;
        }
    } completion:^(BOOL finished) {
    }];
    
    
    [self.tableView reloadData];
}

#pragma mark 全选
- (void)allchoose
{
    //获得videos里为红色的按钮
    NSMutableArray *isAll = [[NSMutableArray alloc]init];
    for (Video *all in videos) {
        if ([all.isRed isEqualToString:@"1"]) {
            [isAll addObject:all];
        }
    }
    //根据红色按钮的个数是否与videos元素个数相等来判断是全变红还是全变白
    NSMutableArray *change = [[NSMutableArray alloc]init];
    if (isAll.count == videos.count) {
        for (Video *cgWhite in videos) {
            cgWhite.isRed = @"0";
            [change addObject:cgWhite];
        }
        [_deselectCell removeAllObjects];
    }else{
        for (Video *cgRed in videos) {
            cgRed.isRed = @"1";
            [change addObject:cgRed];
            [_deselectCell addObject:cgRed];
        }
    }
    videos = change;
    [self.tableView reloadData];
}

#pragma mark 删除
- (void)anyDelete
{
//    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    ApplicationDelegate.manager.responseSerializer.acceptableContentTypes = [ApplicationDelegate.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    for (int i = 0;i < _deselectCell.count;i ++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"DeleteVideo" forKey:@"action"];
        [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
        [dict setValue:[(Video *)_deselectCell[i] clipId] forKey:@"videoId"];
        
        [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSXMLParser *parser = (NSXMLParser *)responseObject;
            NSError *error = nil;
            NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
            NSLog(@"=====%@",xmlDict);
        } failure:self.errorInfo];
    }
    [videos removeObjectsInArray:_deselectCell];
    [_deselectCell removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark 获得即将被删除的cell模型数组
- (NSMutableArray *)getDeselectCell
{
    return _deselectCell;
}

#pragma mark 获取cell的模型数组
- (NSMutableArray *)videosElement
{
    return videos;
}

@end
