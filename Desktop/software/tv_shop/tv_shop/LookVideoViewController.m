//
//  LookVideoViewController.m
//  tv_shop
//
//  Created by mac on 15/10/28.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//
//#define imageLoveID arc4random_uniform(7)

#import "LookVideoViewController.h"
#import "Viewer.h"
#import "ViewerTableViewCell.h"
#import "MsgTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "ShowViewerViewController.h"
#import "KGModal.h"
#import "VMediaPlayerDelegate.h"
#import "VMediaPlayer.h"
#import "XMLReader.h"
#import "BufferView.h"
#import "TimeoutManager.h"
#import "LookVideoExitView.h"
#import "Love.h"
#import "ShareViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "MyImage.h"
@interface LookVideoViewController ()<UITableViewDataSource,UITableViewDelegate,VMediaPlayerDelegate,ViewControllerReturnDelegate,UIScrollViewDelegate>{
    NSString *url;
    NSMutableDictionary *dic;
    NSMutableArray *viewers;
    UITableView *table;//观看直播的人数据展示用
//    NSThread *thread;//请求聊天数据的线程
    NSTimer *timer;//请求聊天数据的定时器
    NSMutableArray *msgs;
    NSString *msgFromTime;//请求聊天信息开始时间
    BufferView *bufferView;//直播前缓冲图像
    NSMutableArray *heightOfCells;
    CGFloat totalHeightOfCells;
    BOOL msgTextFirstResponder;
//    int loveID;  //图片ID
    BOOL loveFile;  //判断是否发送过爱心
    NSUInteger lastCount;
    TimeoutManager *timeoutManager;
    ShareViewController *share;
    UIView *_shareView;
    UIImageView *_imgView;
    BOOL isShare;
    UIScrollView *_scrollView;
    UIView *_redView;
    UIButton *_click;
}
@property (nonatomic,retain) VMediaPlayer *player;
//@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (weak, nonatomic) IBOutlet UIView *container; //播放器容器
@property (weak, nonatomic) IBOutlet UIProgressView *progress;//播放进度

@end

@implementation LookVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Do any additional setup after loading the view from its nib.
    self.player = nil;
    msgFromTime = @"";
    lastCount = 0;
    [self changeViewerWithAction:@"SetSpaceAudience"];//增加一个观看者
    
    [self setBoundsWithView:self.liveUserPic borderColor:[UIColor whiteColor].CGColor borderWidth:1 masks:YES cornerRadius:22.5];
    NSURL *headPicUrl = [NSURL URLWithString:self.room.userPic];
    self.liveUserPic.contentMode = UIViewContentModeScaleAspectFill;
    [self.liveUserPic sd_setImageWithURL:headPicUrl placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"主播头像加载错误 %@",error);
    }];
    url = @"";
    self.showMsgTable.dataSource = self;
    self.showMsgTable.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"MsgTableViewCell" bundle:nil];
    [self.showMsgTable registerNib:nib forCellReuseIdentifier:[MsgTableViewCell ID]];
    
    [self createViewerTable];
    viewers = [NSMutableArray array];
    
    msgs = [NSMutableArray array];
    
    [self registerForKeyboardNotifications];
    [self setBoundsWithView:self.msgText borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.sendBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    
    [self setBoundsWithView:self.playerHeadView borderColor:[UIColor whiteColor].CGColor borderWidth:1 masks:YES cornerRadius:22.5];
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight)];
    right.numberOfTouchesRequired = 2;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:right];
    
    timeoutManager = [[TimeoutManager alloc] init];
    timeoutManager.delegate = self;
    
    self.shareReturn = NO;
    msgTextFirstResponder = NO;
//    loveID = arc4random_uniform(7);//生成随机图片
    loveFile = YES;//给观众默认图片颜色
    [Love timerWithLove:_btnLove loveID:nil view:self.view time:6 cycle:NO];
    
    //创建分享弹窗
//    share = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
//    [share shareWithFrame:self.shareBtn];
//    [self addChildViewController:share];
//    [self.view addSubview:share.view];
    _shareView = [[UIView alloc] init];
    _imgView = [[UIImageView alloc] init];
    isShare = NO;
}

-(void)swipeToRight {
    [self playClick:nil];
}


- (void)startLoopNew {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(getChatMsgs) userInfo:nil repeats:NO];
}

//横向tableView显示观看头像
-(void)createViewerTable{
    table  = [[UITableView alloc] initWithFrame:self.view.frame];
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [table.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    table.transform = CGAffineTransformMakeRotation(M_PI/-2);
    table.showsVerticalScrollIndicator = NO;
    CGRect frame = self.playerHeadView.frame;
    table.frame = CGRectMake(frame.size.width+frame.origin.x*1.5, frame.size.height+frame.origin.y, self.view.frame.size.width-(frame.size.width+frame.origin.x*2), frame.size.height);
    table.rowHeight = frame.size.height+frame.origin.x;
//    NSLog(@"%f,%f,%f,%f",table.frame.origin.x,table.frame.origin.y,table.frame.size.width,table.frame.size.height);
    table.delegate = self;
    table.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"ViewerTableViewCell" bundle:nil];
    [table registerNib:nib forCellReuseIdentifier:[ViewerTableViewCell ID]];
    [self.view addSubview:table];
}

#pragma mark 缓冲页面
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.shareReturn) {
        [self.sendMsgView setHidden:YES];
        NSLog(@"分享返回页面");
    }else{
        bufferView = [BufferView buffer:self.room.userName imagePath:self.room.userPic];
        bufferView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//        [bufferView addGestureRecognizer:right];
        [self.view addSubview:bufferView];
        [self getVideoUrl];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num;
    if ([tableView.restorationIdentifier isEqualToString:@"Chat"]) {
        num = msgs.count;
    }else{
        num = viewers.count;
    }
//    [self.showMsgTable selectRowAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    return num;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    ViewerTableViewCell *viewerCell = [tableView dequeueReusableCellWithIdentifier:[ViewerTableViewCell ID]];
    MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell ID]];
    if (![tableView.restorationIdentifier isEqualToString:@"Chat"]) {
//        NSLog(@"viewer=%d数据==========%@",indexPath.row,viewers);
        [self setBoundsWithView:viewerCell.viewerPic borderColor:nil borderWidth:0 masks:YES cornerRadius:22.5];
        viewerCell.transform = CGAffineTransformMakeRotation(M_PI/2);
        [viewerCell setCellValue:[viewers objectAtIndex:indexPath.row]];
        cell = viewerCell;
    }else{
        [msgCell setCellValue:[msgs objectAtIndex:indexPath.row]];
        msgCell.msgContent.numberOfLines = 0;
        cell = msgCell;
//        [self.showMsgTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return cell;
}
//观众头像点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![tableView.restorationIdentifier isEqualToString:@"Chat"]) {
        if (viewers.count!=0) {
            KGModal *kgModal = [KGModal sharedInstance];
            kgModal.closeButtonType = KGModalCloseButtonTypeNone;
            kgModal.tapOutsideToDismiss = YES;
            ShowViewerViewController *controller = [[ShowViewerViewController alloc] init];
            controller.control = self;
            controller.viewer = [viewers objectAtIndex:indexPath.row];
            [kgModal showWithContentViewController:controller andAnimated:YES];
        }
    }
}

-(void)getVideoUrl{
    // 返回的数据格式是html，但是形式是XML
    ApplicationDelegate.manager.responseSerializer.acceptableContentTypes = [ApplicationDelegate.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [ApplicationDelegate.manager.requestSerializer setValue:@"iphone" forHTTPHeaderField:@"userAgent"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.room.liveId forKey:@"cid"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.room.userId forKey:@"pid"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/GetLiveurl.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            if (myParser.parserObjects.count!=0) {
                url = [[myParser.parserObjects objectAtIndex:0] objectForKey:@"PlayUrl"];
            }
        }
//        [self startLoop];
        NSLog(@"视频链接%@", url);
        [self initPlay];
        [self playVideo];
    } failure:self.errorInfo];
}

//改变观看人数
-(void)changeViewerWithAction:(NSString*)action{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:action forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.room.roomId forKey:@"spaceId"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
//        NSLog(@"返回数据%@", dic);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [self showText:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }
    } failure:self.errorInfo];
}

//请求观众信息
-(void)getViewers{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetSpaceAudience" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.room.roomId forKey:@"spaceId"];
    
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
//        NSLog(@"返回数据%@", dic);
        [viewers removeAllObjects];
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [self showText:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            NSArray *datas = [dic objectForKey:@"DataInfos"];
            if (datas.count!=0) {
                //加载观看直播数据
                [viewers addObjectsFromArray:[Viewer saveToModelWithDicarr:datas]];
            }
            [self.viewerCount setText:[NSString stringWithFormat:@"%d",viewers.count]];
            [table reloadData];
        }
    } failure:self.errorInfo];
}

//请求聊天数据
-(void)getChatMsgs{
    [self getViewers];
    // 返回的数据格式是XML
    
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"GetPollData" forKey:@"action"];
    [params setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [params setObject:self.room.roomId forKey:@"spaceId"];
    [params setObject:self.room.liveId forKey:@"channelId"];
    if([msgFromTime isEqualToString:@""]){
        msgFromTime = [self getTimeStringWithDate:[NSDate date]];
    }
    [params setObject:msgFromTime forKey:@"lastChatInfoTime"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/LiveAutoPoll.aspx" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        //如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        //第三方库第三方框架,效率低,内存泄漏
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *dict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
        
//        NSLog(@"返回数据%@", dict);
        if (![dict[@"DataInfos"][@"Head"][@"Error_Id"][@"text"] isEqualToString:@"00"]) {
            [self showText:dict[@"DataInfos"][@"Head"][@"Error_Desc"][@"text"]];
        }else{
            //获得倒序后的数组
//            NSMutableArray *msgTemp = [NSMutableArray array];
            NSDictionary *chatList = dict[@"DataInfos"][@"ChatList"];
            if (chatList != nil && [chatList count] > 0) {
                NSMutableArray *msgTemp;
                if ([chatList[@"ChatDataInfo"] isKindOfClass:[NSArray class]]) {
                    //TODO
                    msgTemp = (NSMutableArray *)[[chatList[@"ChatDataInfo"] reverseObjectEnumerator] allObjects];
                }
                else {
                    msgTemp = [NSMutableArray arrayWithObject:chatList[@"ChatDataInfo"]];
                }
                if (msgTemp != nil && msgTemp.count > 0) {
                        [msgs addObjectsFromArray:msgTemp];
                        [self updateViewHeightWithMsgs:msgs];
                        msgFromTime = [msgs lastObject][@"SendTime"][@"text"];
//                    NSLog(@"=====%@",msgs);
                }
                [self updateMsgTableView:[msgs count]];
                [self.showMsgTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                for (NSUInteger i = 0; i <[msgTemp count];i++) {
                    if ((msgTemp[i][@"UserName"] !=[LocalUser getName]) && [msgTemp[i][@"ChatDesc"][@"text"] isEqual:(@"送给主播一个♥")] ) {
                        [Love timerWithLove:_btnLove loveID:nil view:self.view time:0.5 cycle:YES];
                    }
                };
            }
        }
        if([self.player isPlaying]){
            [self getChatMsgs];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError *  error) {
        NSLog(@"%@", error);
        if([self.player isPlaying]){
            [self getChatMsgs];
        }
    }];
 
}
-(void)updateViewHeightWithMsgs:(NSArray *)ms {
    if(heightOfCells ==nil) {
        heightOfCells = [[NSMutableArray alloc] init];
    }
    if ([heightOfCells count] > 0) {
        [heightOfCells removeAllObjects];
    }
    NSUInteger count = ms.count;
    CGFloat totalHeight = 0;
    for(NSUInteger i = 0; i < count; ++i) {
        NSString *msgFrom = [NSString stringWithFormat:@"%@:",ms[i][@"UserName"][@"text"]];
        NSString *msgContent = ms[i][@"ChatDesc"][@"text"];
        CGSize sizeOfFromLabel = [msgFrom
                    boundingRectWithSize:CGSizeMake(self.showMsgTable.frame.size.width, CGFLOAT_MAX)
                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                    context:nil].size;
        CGSize sizeOfMsgLabel = [msgContent
                       boundingRectWithSize:CGSizeMake(self.showMsgTable.frame.size.width - sizeOfFromLabel.width - 30, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                            context:nil].size;
        sizeOfMsgLabel.height =  MAX(sizeOfMsgLabel.height, 22);
        totalHeight += sizeOfMsgLabel.height;
        [heightOfCells addObject:[NSNumber numberWithDouble:sizeOfMsgLabel.height]];
    }
    totalHeightOfCells = totalHeight;
}
//更新消息列表
-(void)updateMsgTableView:(NSUInteger)msgCount {

    if (msgCount <= 0) {
        return;
    }
    //获取当前焦点
    if (msgCount != lastCount) {
        lastCount = msgCount;
        CGFloat height = [self msgTableViewHeight];
        if (height > 150) {
            self.layoutMsgTableHeight.constant = 150;
            [self.showMsgTable setContentOffset:CGPointMake(0, height - 150) animated:YES];
        }
        else {
            self.layoutMsgTableHeight.constant = height;
        }
    }
    //恢复焦点
  
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.restorationIdentifier isEqualToString:@"Chat"]) {
        if (heightOfCells == nil || [heightOfCells count] == 0) {
            return 0;
        }
        CGFloat height = [heightOfCells[indexPath.row] doubleValue];
        return height;
    }
    else {
        return 45.0;
    }
}

-(CGFloat)msgTableViewHeight {
    return totalHeightOfCells;
}

//发送聊天信息
-(void)sendMsgNetWork:(NSString*)msg{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"AddChatMsg" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.room.roomId forKey:@"spaceId"];
    [dict setObject:self.room.liveId forKey:@"channelId"];
    [dict setObject:msg forKey:@"msg"];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/LiveInterface.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
//        NSLog(@"返回数据%@", dic);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [self showText:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            NSArray *datas = [dic objectForKey:@"DataInfos"];
            if (datas.count!=0) {
//                [self.msgView reloadData];
            }
        }
//        [self getChatMsgs];
    } failure:self.errorInfo];
}

-(void)exit{
    [self.returnDelegate returnToLastViewController:self];
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playClick:(UIButton *)sender {
    [self stopVideo];
    [self changeViewerWithAction:@"RemovedSpaceAudience"];
    [self exit];
}

- (IBAction)openSendView:(UIButton *)sender {
    msgTextFirstResponder = YES;
    [self.msgText setText:@""];
    [self.msgText becomeFirstResponder];
}

- (IBAction)sendMsg:(UIButton *)sender {
    [self sendMsgNetWork:self.msgText.text];
    [self.msgText resignFirstResponder];
    [self.sendMsgView setHidden:YES];
    msgTextFirstResponder = NO;
}

#pragma mark 点击屏幕播放“爱心”动画
- (IBAction) loveClick
{
    if (loveFile){
        [self sendMsgNetWork:@"送给主播一个♥"];
        loveFile = NO;
    }
    [Love timerWithLove:_btnLove loveID:nil view:self.view time:0.5 cycle:YES];
}

//触摸非输入框隐藏键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.msgText isFirstResponder])
    {
        [self.msgText resignFirstResponder];
        [self.sendMsgView setHidden:YES];
        msgTextFirstResponder = NO;
    }
}
//获取键盘高度的通知注册
- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}
//键盘显示通知触发
- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    [UIView animateWithDuration:0.5 animations:^{
        [self.sendMsgView setHidden:NO];
        //[self.sendMsgView setFrame:CGRectMake(0, self.view.frame.size.height-keyboardSize.height-self.sendMsgView.frame.size.height, self.sendMsgView.frame.size.width, self.sendMsgView.frame.size.height)];
        self.layoutSendMsgViewBottom.constant = - keyboardSize.height;
    } completion:^(BOOL finished) {
        
    }];
}
//键盘隐藏通知触发
- (void) keyboardWasHidden:(NSNotification *) notif
{
 /*
    [UIView animateWithDuration:0.5 animations:^{
        [self.sendMsgView setHidden:YES];
        [self.sendMsgView setFrame:CGRectMake(0, self.view.frame.size.height + self.sendMsgView.frame.size.height, self.sendMsgView.frame.size.width, self.sendMsgView.frame.size.height)];
    } completion:^(BOOL finished) {
        self.layoutSendMsgViewBottom.constant = self.sendMsgView.frame.size.height;
    }];
  */
}

#pragma mark 分享
- (IBAction)shareVideo:(UIButton *)sender {
    isShare = !isShare;
    UIButton *tempBtn = (UIButton *)sender;
    _shareView.frame = CGRectMake(tempBtn.frame.origin.x - 15, tempBtn.frame.origin.y - 110, 90, 100);
    _imgView.image = [UIImage imageNamed:@"background"];
    _imgView.frame = CGRectMake(0, 0, 90, 100);
    _imgView.contentMode = UIViewContentModeScaleToFill;
    if (isShare) {
        [_shareView addSubview:_imgView];
        [self.view addSubview:_shareView];
        UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QQ@2x"]];
        img1.frame = CGRectMake(7, 5, 20, 20);
        img1.layer.cornerRadius = 10;
        [_shareView addSubview:img1];
        
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, 55, 30)];
        btn1.tag = 1001;
        [btn1 setTitle:@"QQ" forState:UIControlStateNormal];
        btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [_shareView addSubview:btn1];
        
        UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weixin@2x"]];
        img2.frame = CGRectMake(7, 35, 20, 20);
        img2.layer.cornerRadius = 10;
        [_shareView addSubview:img2];
        
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 55, 30)];
        btn2.tag = 1002;
        [btn2 setTitle:@"微信" forState:UIControlStateNormal];
        btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [_shareView addSubview:btn2];
        
        UIImageView *img3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weixin2@3x"]];
        img3.frame = CGRectMake(7, 65, 20, 20);
        img3.layer.cornerRadius = 10;
        [_shareView addSubview:img3];
        
        UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(30, 60, 55, 30)];
        btn3.tag = 1003;
        [btn3 setTitle:@"朋友圈" forState:UIControlStateNormal];
        btn3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn3 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [_shareView addSubview:btn3];
    } else {
        for (UIView *v in _shareView.subviews) {
            [v removeFromSuperview];
        }
        [_shareView removeFromSuperview];
    }
}
//点击分享平台
- (void)tapAction:(UIButton *)btn {
    int tag = btn.tag - 1000;
    if (tag == 1) {
        //分享到QQ
        //判断是否安装了QQ
        if ([QQApiInterface isQQInstalled]) {
            NSString *utf8String = [NSString stringWithFormat:@"http://60.190.202.135/wap/N.aspx?cid=%@&pid=%@",self.room.liveId,self.room.userId];
            NSString *title = [NSString stringWithFormat:@"%@的直播间",self.room.userName];
            NSString *description = @"一起加入精彩的直播吧";
            NSString *previewImageUrl = self.room.userPic;
            QQApiNewsObject *newsObj = [QQApiNewsObject
                                        objectWithURL:[NSURL URLWithString:utf8String]
                                        title:title
                                        description:description
                                        previewImageURL:[NSURL URLWithString:previewImageUrl]];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
            //将内容分享到qq
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您没有安装QQ！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else {
        //判断是否安装了微信
        if ([WXApi isWXAppInstalled]) {
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            if (tag == 2) {
                //分享到微信好友
                sendReq.scene = 0;
            } else if (tag == 3) {
                //分享到朋友圈
                sendReq.scene = 1;
            }
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            //分享标题
            urlMessage.title = [NSString stringWithFormat:@"%@的直播间",self.room.userName];
            //分享描述
            urlMessage.description = @"欢迎观看直播";
            //分享图片
            [urlMessage setThumbImage:[UIImage imageNamed:@"icon29@2x"]];
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            //分享链接
            webObj.webpageUrl = [NSString stringWithFormat:@"http://60.190.202.135/wap/N.aspx?cid=%@&pid=%@",self.room.liveId,self.room.userId];
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
            sendReq.message = urlMessage;
            //发送分享消息
            [WXApi sendReq:sendReq];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您没有安装微信！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    for (UIView *v in _shareView.subviews) {
        [v removeFromSuperview];
    }
    [_shareView removeFromSuperview];
    isShare = !isShare;
}

-(void)timeoutDidStart:(TimeoutManager *)manager {
    [self showText:@"请求超时"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self playClick:nil];
    });
}

//播放器代码
-(void)initPlay{
    self.player = [VMediaPlayer sharedInstance];
//    [self.player setupPlayerWithCarrierView:self.container withDelegate:self];
    while(![self.player setupPlayerWithCarrierView:self.container withDelegate:self])
    {
        [self.player reset];
        [self.player unSetupPlayer];
    }
}

-(void)playVideo{
    [self.player setDataSource:[NSURL URLWithString:url] header:nil];
    [self.player prepareAsync];
    [timeoutManager startWaitTimeout:5.0];
}

-(void)stopVideo{
    [self.player reset];
    [self.player unSetupPlayer];
}

// 当'播放器准备完成'时, 该协议方法被调用, 我们可以在此调用 [player start]
// 来开始音视频的播放.
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [bufferView removeFromSuperview];
    [timeoutManager cancelTimeoutOperation];
    [self startLoopNew];
    [player start];
}
// 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后
// 操作, 如: 重置播放器, 准备播放下一个音视频等
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [player reset];
    LookVideoExitView *exit = [[LookVideoExitView alloc]init];
    exit.room=self.room;//将room里的值转给exit
    exit.attentionDelegate = (id)self.returnDelegate;//设置首页为exit的代理
    exit.returnDelegate = self;
    [self.navigationController pushViewController:exit animated:YES];
}
// 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参
// 数 arg 包含了错误原因.
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    [bufferView removeFromSuperview];
    [self showText:@"播放失败"];
//    NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
    NSLog(@"%@", arg);
}

//关注主播接口请求
-(void)addAttention:(NSString *)attentionId{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"AddFocus" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    [dict setObject:attentionId forKey:@"UserId"];
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//        NSLog(@"%@", xmlDict);
    } failure:self.errorInfo];
}

-(NSString*)getTimeStringWithDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *time = [formatter stringFromDate:date];
//    NSLog(@"时间为 %@",time);
    return time;
}

#pragma mark 返回首页 (代理实现方法)
-(void)returnToLastViewController:(UIViewController *)viewController{
    [self playClick:nil];
}

#pragma mark 头像点击获取信息
-(IBAction)liveUserClick
{
    //设置弹框
    KGModal *kgModal = [KGModal sharedInstance];
    kgModal.closeButtonType = KGModalCloseButtonTypeNone;
    kgModal.tapOutsideToDismiss = YES;
    __block ShowViewerViewController *controller = [[ShowViewerViewController alloc] init];
    controller.control = self;
    //获取数据
    __block Viewer *viewer1 = [[Viewer alloc]init];
    viewer1.userName = self.room.userName;
    viewer1.yanZhi = self.room.userFaceLevel;
    viewer1.userPic = self.room.userPic;
    viewer1.roomId = self.room.liveId;
    
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetUserInfo" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:self.room.userId forKey:@"userId"];
    [dict setObject:@"1" forKey:@"PageNo"];
    //网络请求
    [ApplicationDelegate.manager GET:@"wap/LiveInterface.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"======%@",operation);
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
//        NSLog(@"=====%@",xmlDict);
        
        viewer1.attetionCount = xmlDict[@"DataInfos"][@"DataInfo"][@"UserInfo"][@"Focus"][@"text"];
        viewer1.fansCount = xmlDict[@"DataInfos"][@"DataInfo"][@"UserInfo"][@"Fans"][@"text"];
        viewer1.liveCount = xmlDict[@"DataInfos"][@"DataInfo"][@"UserInfo"][@"LiveCount"][@"text"];
        controller.viewer = viewer1;
        //显示
        [kgModal showWithContentViewController:controller andAnimated:YES];

    } failure:self.errorInfo];
}

- (NSString *)getRoomId
{
    return self.room.liveId;
}
#pragma mark 点击商品按钮
- (IBAction)checkGoods:(id)sender {
    _click = (UIButton *)sender;
    _click.userInteractionEnabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, h - h/3 - 75, w - 10, h/3)];
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(4 * (w-10), 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    //底部红线
    _redView = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_scrollView.frame)-5, (w-10)/4, 5)];
    _redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_redView];
    
    for (int i = 0; i < 4; i ++) {
        UIImageView *imgView = [MyImage createImgViewWith:CGRectMake(i * (w - 10), 0, w - 10, h/3) imgName:[NSString stringWithFormat:@"mylove%d",i + 1]];
        imgView.contentMode = UIViewContentModeScaleToFill;
        imgView.userInteractionEnabled = YES;
        [_scrollView addSubview:imgView];
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w - 50,h - h/3 - 75 - 25, 50, 50)];
    btn.layer.cornerRadius = 25;
    [btn setBackgroundImage:[UIImage imageNamed:@"close" ] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)closeAction:(UIButton *)btn {
    _click.userInteractionEnabled = YES;
    [btn removeFromSuperview];
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    [_redView removeFromSuperview];
    [_scrollView removeFromSuperview];
}

#pragma mark scrollView代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = _scrollView.contentOffset.x/_scrollView.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _redView.frame = CGRectMake(index * _scrollView.frame.size.width/4+5, CGRectGetMaxY(_scrollView.frame)-5, _scrollView.frame.size.width/4, 5);
    }];
}

@end
