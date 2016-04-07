//
//  PlayViewController.m
//  tv_shop
//
//  Created by mac on 15/10/20.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "PlayViewController.h"
#import "LiveStreamingService.h"
#import "KGModal.h"
#import "RSAVCamCaptureManager.h"
#import "ExitDialogViewController.h"
#import "ViewerTableViewCell.h"
#import "Viewer.h"
#import "MsgTableViewCell.h"
#import "ShowViewerViewController.h"
#import "XMLReader.h"
#import "Love.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <TencentOpenAPI/QQApiInterface.h>
LiveStreamingService* liveTool;
RSMyAVCamCaptureManager *captureMgr;
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface PlayViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>{
    BOOL isLive;
    NSMutableDictionary *dic;
    UITableView *table;//观看直播的人数据展示用
    NSMutableArray *viewers;
    NSThread *thread;//请求聊天数据的线程
    NSTimer *timer;//请求聊天数据的定时器
    NSMutableArray *msgs;
    BOOL shareReturn;//分享之后返回页面
    NSString *msgFromTime;//请求聊天信息开始时间
    NSMutableArray *heightOfCells;
    BOOL msgTextFirstResponder;
    CGFloat totalHeightOfCells;
    UIView *_shareView;
    UIImageView *_imgView;
    BOOL isShare;
}

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //长亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Do any additional setup after loading the view from its nib.
    msgFromTime = @"";
    [self changeViewerWithAction:@"SetSpaceAudience"];
    
    self.msgView.dataSource = self;
    self.msgView.delegate = self;
    self.msgText.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"MsgTableViewCell" bundle:nil];
    [self.msgView registerNib:nib forCellReuseIdentifier:[MsgTableViewCell ID]];
    msgs = [NSMutableArray array];
    
    self.hud = nil;
    [self registerForKeyboardNotifications];
    [self setBoundsWithView:self.msgText borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    [self setBoundsWithView:self.sendBtn borderColor:nil borderWidth:0 masks:YES cornerRadius:4];
    
    [self createViewerTable];
    viewers = [NSMutableArray array];
//    [self getChatMsgs];//获取聊天记录
    [self startLoopNew];
    
    [self showTextDialog:@"正在启动..."];
    liveTool = [[LiveStreamingService alloc] init];
    captureMgr = [[RSMyAVCamCaptureManager alloc] init];
    [self.playView setFrame:[UIScreen mainScreen].bounds];
    
    [captureMgr setupSessionWithPreviewView:self.view backCamera:YES];
    captureMgr.delegate = liveTool;
    if (captureMgr !=nil)
    {
        [captureMgr startRunning];
    }
    
//    NSLog(@"直播id%@",self.cid);
//    NSLog(@"直播ip和port%@   %@",self.liveIp,self.livePort);
    [liveTool initWithServerIP:self.liveIp port:[self.livePort integerValue] channelID:self.cid];
    
    shareReturn = NO;
    
    _shareView = [[UIView alloc] init];
    _imgView = [[UIImageView alloc] init];
    isShare = NO;
}

-(void)startLoopNew {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getChatMsgs) userInfo:nil repeats:NO];
}

- (void)startLoop
{
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(loopMethod) object:nil];
    [thread start];
}

- (void)loopMethod
{
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(getChatMsgs) userInfo:nil repeats:YES];
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    [loop run];
}

-(void)createViewerTable{
    table  = [[UITableView alloc] initWithFrame:self.view.frame];
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [table.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    table.transform = CGAffineTransformMakeRotation(M_PI/-2);
    table.showsVerticalScrollIndicator = NO;
    CGRect frame = self.peopleIcon.frame;
    table.frame = CGRectMake(frame.size.width+frame.origin.x*1.5, frame.size.height+frame.origin.y, self.view.frame.size.width-(frame.size.width+frame.origin.x*2), frame.size.height);
    table.rowHeight = frame.size.width+frame.origin.x;
//    NSLog(@"%f,%f,%f,%f",table.frame.origin.x,table.frame.origin.y,table.frame.size.width,table.frame.size.height);
    table.delegate = self;
    table.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"ViewerTableViewCell" bundle:nil];
    [table registerNib:nib forCellReuseIdentifier:[ViewerTableViewCell ID]];
    [self.view addSubview:table];
}

-(void)viewDidAppear:(BOOL)animated{
    if (shareReturn) {
        [self.sendMsgView setHidden:YES];
        NSLog(@"分享返回页面");
    }else{
        [super viewDidAppear:animated];
        isLive = NO;
        __block int timeout=3; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){ //倒计时结束,开始直播
                dispatch_source_cancel(_timer);
                [self controlPlay:nil];
            }else{
                timeout--;
            }
        });
        dispatch_resume(_timer);
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [thread cancel];
    [timer invalidate];
    [self changeViewerWithAction:@"RemovedSpaceAudience"];
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
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *restorationIndentifier = tableView.restorationIdentifier;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    ViewerTableViewCell *viewerCell = [tableView dequeueReusableCellWithIdentifier:[ViewerTableViewCell ID]];
    CGRect temp = viewerCell.viewerPic.frame;//改图像尺寸
    temp.size.width = (4*viewerCell.frame.size.height)/3;
    MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell ID]];
    if (![tableView.restorationIdentifier isEqualToString:@"Chat"]) {
        [self setBoundsWithView:viewerCell.viewerPic borderColor:nil borderWidth:0 masks:YES cornerRadius:22.5];
        viewerCell.transform = CGAffineTransformMakeRotation(M_PI/2);
        [viewerCell setCellValue:[viewers objectAtIndex:indexPath.row]];
        cell = viewerCell;
    }else{
        [msgCell setCellValue:[msgs objectAtIndex:indexPath.row]];
        cell = msgCell;
        [self.msgView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![tableView.restorationIdentifier isEqualToString:@"Chat"]) {
        if (viewers.count!=0) {
            KGModal *kgModal = [KGModal sharedInstance];
            kgModal.closeButtonType = KGModalCloseButtonTypeNone;
            kgModal.tapOutsideToDismiss = YES;
            ShowViewerViewController *controller = [[ShowViewerViewController alloc] init];
            controller.viewer = [viewers objectAtIndex:indexPath.row];
            [kgModal showWithContentViewController:controller andAnimated:YES];
        }
    }
}

- (IBAction)controlPlay:(UIButton *)sender {
    if (isLive) {
        [self exitLive];
    }else{
        [self.hud setHidden:YES];
        self.hud = nil;
//        [self startLoopNew];
//        [self beginLive:nil];
        isLive = YES;
    }
}

//-(void)beginLive:(id)sender{
//    if(captureMgr)
//    {
//        captureMgr.delegate = liveTool;
//        [liveTool startService];
//        if (captureMgr !=nil)
//        {
//            [captureMgr startRunning];
//        }
//    }
//}

- (void)stopLive:(id)sender {
    if(captureMgr)
    {
        isLive = NO;
        [captureMgr stopRunning];
        [liveTool stopService];
        [self stopLiveNet];
    }
}

-(void)exitLive{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:KGModalWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShow:) name:KGModalDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:KGModalWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:KGModalDidHideNotification object:nil];
    [self showDialog:nil];
}

//退出直播弹窗
- (void)showDialog:(id)sender{
    ExitDialogViewController *controller = [[ExitDialogViewController alloc] init];
    [controller.view setFrame:CGRectMake(0, 0, 280, controller.view.frame.size.height)];
    KGModal *kgModal = [KGModal sharedInstance];
    kgModal.tapOutsideToDismiss = NO;
    kgModal.closeButtonType = KGModalCloseButtonTypeNone;
    [kgModal showWithContentViewController:controller andAnimated:YES];
    controller.kgModal = kgModal;
    controller.nav = self.navigationController;
    controller.baseController = self;
}

- (void)willShow:(NSNotification *)notification{
    NSLog(@"will show");
}

- (void)didShow:(NSNotification *)notification{
    NSLog(@"did show");
}

- (void)willHide:(NSNotification *)notification{
    NSLog(@"will hide");
}

- (void)didHide:(NSNotification *)notification{
    NSLog(@"did hide");
}

- (IBAction)controlLight:(UIButton *)sender {
//    NSLog(@"------%ld",(long)[[captureMgr.videoInput device] position]);
    if ([[captureMgr.videoInput device] position]<=1) {
        [captureMgr toggleTorch];
    }else{
        [self showText:@"无可用闪光灯"];
    }
}

- (IBAction)controlCamera:(UIButton *)sender {
    [captureMgr toggleCamera];
    [self animationWithView:self.view WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
}
//打开发送消息界面
- (IBAction)sendMsg:(UIButton *)sender {
    [self.msgText setText:@""];
    [self.msgText becomeFirstResponder];
}
//聊天消息发送
- (IBAction)send:(UIButton *)sender {
    [self sendMsgNetWork];
    [self.msgText resignFirstResponder];
    [self.sendMsgView setHidden:YES];
}
//触摸非输入框隐藏键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.msgText resignFirstResponder];
    [self.sendMsgView setHidden:YES];
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
//    NSLog(@"==============%f",keyboardSize.height);
    [UIView animateWithDuration:0.5 animations:^{
        [self.sendMsgView setHidden:NO];
        [self.sendMsgView setFrame:CGRectMake(0, self.view.frame.size.height-keyboardSize.height-self.sendMsgView.frame.size.height, self.sendMsgView.frame.size.width, self.sendMsgView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
}
//键盘隐藏通知触发
- (void) keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
}

//请求聊天数据
-(void)getChatMsgs{
    [self getViewers];
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"GetPollData" forKey:@"action"];
    [params setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [params setObject:[LocalUser getRoomId] forKey:@"spaceId"];
    [params setObject:self.cid forKey:@"channelId"];
    if([msgFromTime isEqualToString:@""]){
        msgFromTime = [self getTimeStringWithDate:[NSDate date]];
    }
    [params setObject:msgFromTime forKey:@"lastChatInfoTime"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/LiveAutoPoll.aspx" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
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
                }
                
                [self updateMsgTableView:[msgs count]];
                [self.msgView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                for (NSUInteger i = 0; i <[msgTemp count];i++) {
                    if ([msgTemp[i][@"ChatDesc"][@"text"] isEqual:(@"送给主播一个♥")] ) {
                        [Love timerWithLove:_btnLove loveID:8 view:self.view time:0.5 cycle:YES];
                    }
                };
               
            }
        }
        [self performSelectorOnMainThread:@selector(startLoopNew) withObject:nil waitUntilDone:NO];
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        NSLog(@"%@", error);
        [self performSelectorOnMainThread:@selector(startLoopNew) withObject:nil waitUntilDone:NO];
    }];

}

-(void)updateViewHeightWithMsgs:(NSArray *)ms {
    if(heightOfCells == nil) {
        heightOfCells = [[NSMutableArray alloc] init];
    }
    if ([heightOfCells count] > 0) {
        [heightOfCells removeAllObjects];
    }
    NSUInteger count = [ms count];
    CGFloat totalHeight = 0;
    for(NSUInteger i = 0; i < count; ++i) {
        NSString *msgFrom = [NSString stringWithFormat:@"%@:",ms[i][@"UserName"][@"text"]];
        NSString *msgContent = ms[i][@"ChatDesc"][@"text"];
        CGSize sizeOfFromLabel = [msgFrom
                                  boundingRectWithSize:CGSizeMake(self.msgView.frame.size.width, CGFLOAT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                                  context:nil].size;
        CGSize sizeOfMsgLabel = [msgContent
                                 boundingRectWithSize:CGSizeMake(self.msgView.frame.size.width - sizeOfFromLabel.width - 30, CGFLOAT_MAX)
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                 context:nil].size;
        sizeOfMsgLabel.height = MAX(sizeOfMsgLabel.height, 22);
        totalHeight += sizeOfMsgLabel.height;
        [heightOfCells addObject:[NSNumber numberWithDouble:sizeOfMsgLabel.height]];
    }
    totalHeightOfCells = totalHeight;
}

//更新消息列表
-(void)updateMsgTableView:(NSUInteger)msgCount {
    static NSUInteger lastCount = 0;
    if (msgCount <= 0) {
        return;
    }
    //获取当前焦点
    if (msgCount != lastCount) {
        lastCount = msgCount;
        CGFloat height = [self msgTableViewHeight];
        if (height > 150) {
            self.layoutMsgTableHeight.constant = 150;
            [self.msgView setContentOffset:CGPointMake(0, height - 150) animated:YES];
        }
        else {
            self.layoutMsgTableHeight.constant = height;
        }
    }
    //恢复焦点
    
}

-(CGFloat)msgTableViewHeight {
    return totalHeightOfCells;
}

//发送聊天信息
-(void)sendMsgNetWork{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"AddChatMsg" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:[LocalUser getRoomId] forKey:@"spaceId"];
    [dict setObject:self.cid forKey:@"channelId"];
    [dict setObject:self.msgText.text forKey:@"msg"];
    
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
            [MyAlertHelper modelWithMsg:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            NSArray *datas = [dic objectForKey:@"DataInfos"];
            if (datas.count!=0) {
                [self.msgView reloadData];
            }
        }
    } failure:self.errorInfo];
}

//改变观看人数
-(void)changeViewerWithAction:(NSString*)action{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:action forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"sessionKey"];
    [dict setObject:[LocalUser getRoomId] forKey:@"spaceId"];
    
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
    [dict setObject:[LocalUser getRoomId] forKey:@"spaceId"];
    
    [viewers removeAllObjects];
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
//        NSLog(@"viewers %@",viewers);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [MyAlertHelper modelWithMsg:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }else{
            NSArray *datas = [dic objectForKey:@"DataInfos"];
            if (datas.count!=0) {
                //加载观看直播数据
                [viewers addObjectsFromArray:[Viewer saveToModelWithDicarr:datas]];
            }
            [self.viewerNum setText:[NSString stringWithFormat:@"%d",viewers.count]];
            [table reloadData];
        }
    } failure:self.errorInfo];
}

//直播结束
-(void)stopLiveNet{
    //支持返回html格式数据
    ApplicationDelegate.manager.responseSerializer.acceptableContentTypes = [ApplicationDelegate.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *session = [[LocalUser getSession] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:session forKey:@"userToken"];
    [dict setObject:self.cid forKey:@"ChannelId"];
    
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"wap/LiveStop.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        // 第三方库第三方框架,效率低,内存泄漏
        MyXMLParser *myParser = [MyXMLParser createParser];
        if ([myParser parser:responseObject]){
            dic = myParser.returnDic;
        }
//        NSLog(@"返回数据%@", dic);
//        NSLog(@"viewers %@",viewers);
        if (![[[dic objectForKey:@"Head"] objectForKey:@"Error_Id"] isEqualToString:@"00"]) {
            [MyAlertHelper modelWithMsg:[[dic objectForKey:@"Head"] objectForKey:@"Error_Desc"]];
        }
    } failure:self.errorInfo];
}

#pragma mark 分享三平台
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
        // QQ
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
        //微信好友
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
        //朋友圈
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
        for (UIView *view in _shareView.subviews) {
            [view removeFromSuperview];
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
            NSString *utf8String = [NSString stringWithFormat:@"http://60.190.202.135/wap/N.aspx?cid=%@&pid=%@",self.cid,[LocalUser getId]];
            NSString *title = [NSString stringWithFormat:@"%@的直播间",[LocalUser getName]];
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
            urlMessage.title = [NSString stringWithFormat:@"%@的直播间",[LocalUser getName]];
            //分享描述
            urlMessage.description = @"欢迎观看精彩直播";
            //分享图片
            [urlMessage setThumbImage:[UIImage imageNamed:@"icon29@2x"]];
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            //分享链接
            webObj.webpageUrl = [NSString stringWithFormat:@"http://60.190.202.135/wap/N.aspx?cid=%@&pid=%@",self.cid,[LocalUser getId]];
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


-(NSString*)getTimeStringWithDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *time = [formatter stringFromDate:date];
    NSLog(@"时间为 %@",time);
    return time;
}
@end
