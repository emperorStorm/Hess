//
//  ShowUserDetailViewController.m
//  tv_shop
//
//  Created by mac on 15/11/5.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "ShowUserDetailViewController.h"
#import "MJRefresh.h"
#import "CollectionViewCell.h"
#import "XMLReader.h"
#import "Attentions.h"
#import "UserInfo.h"
#import "VodInfo.h"
#import "UIImageView+WebCache.h"
#import "PlayVideoViewController.h"
#import "ViewControllerReturnDelegate.h"
#import "StartRatingView.h"

@interface ShowUserDetailViewController ()<ViewControllerReturnDelegate>{
    NSInteger page;
    UserInfo *userInfo;
    NSMutableArray *vodInfos;
}
@property (strong, nonatomic) StartRatingView *starRatingView;

@end

@implementation ShowUserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBoundsWithView:self.headImage borderColor:nil borderWidth:0 masks:YES cornerRadius:45];
    [self setViewValue];
    [self setupHeader];
//    [self setupFooter];
    self.scrollView.delegate = self;
    [self setCollectionView];
    [self loadData];
    
}

//-(void)setupRefreshControl {
//    [self setupHeader];
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"0: %f, %f", self.view.frame.origin.y, self.view.frame.size.height);
//    NSLog(@"1: %f, %f", self.scrollView.frame.origin.y, self.scrollView.frame.size.height);
//    
//    NSLog(@"3: %f, %f", self.collectionView.frame.origin.y, self.collectionView.frame.size.height);
}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    
//}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    CGRect rect = [[UIScreen mainScreen] bounds];
//    [self.scrollView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
//    [self.scrollView setContentSize:rect.size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCollectionView {
    vodInfos = [[NSMutableArray alloc] init];
//    UINib *nib = [UINib nibWithNibName:@"CollectionViewCell" bundle:nil];
//    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[CollectionViewCell ID]];
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:[CollectionViewCell ID]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
}
-(void)setViewValue{
    if ([self.data class]==[Fans class]) {
        Fans *fans = (Fans*)self.data;
        [self.nameLabel setText:fans.userName];
        [self.userLevel setText:fans.userLevel];
        [self.userMotto setText:fans.userMotto];
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:fans.userPic] placeholderImage:[UIImage imageNamed:@"icon.png"]];
//        [self.fansCount setText:fans.]
    }
    else {
        Attentions *attention = (Attentions *)self.data;
        [self.nameLabel setText:attention.userName];
        [self.userLevel setText:attention.userLevel];
        [self.userMotto setText:attention.userMotto];
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:attention.userPic] placeholderImage:[UIImage imageNamed:@"icon.png"]];
    }
    
    self.starRatingView = [[StartRatingView alloc] initWithFrame:self.starsView.frame numberOfStar:5];
    [self.starRatingView setValue:0.0 withAnimation:NO];
    [self.faceLevelView addSubview:self.starRatingView];
    [self.faceLevelView addConstraint:[NSLayoutConstraint constraintWithItem:self.starRatingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.starsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.faceLevelView addConstraint:[NSLayoutConstraint constraintWithItem:self.starRatingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.starsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.faceLevelView addConstraint:[NSLayoutConstraint constraintWithItem:self.starRatingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.starsView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.faceLevelView addConstraint:[NSLayoutConstraint constraintWithItem:self.starRatingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.starsView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
}

- (void)loadData{
    // 返回的数据格式是XML
    ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"GetUserInfo" forKey:@"action"];
    [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
    if ([self.data class] == [Fans class]) {
        Fans *fans = (Fans *)self.data;        
        [dict setObject:fans.userId forKey:@"userId"];
    }
    else
    {
        Attentions *attentions = (Attentions *)self.data;
        [dict setObject:attentions.userId forKey:@"userId"];
    }
    // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
    [ApplicationDelegate.manager GET:@"/wap/LiveInterface.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation);
        // 如果结果是XML,同样需要使用6个代理方法解析,或者使用第三方库
        NSXMLParser *responseData = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:responseData options:0 error:&error];
        NSDictionary *xmlUserInfo = [[[xmlDict objectForKey:@"DataInfos"] objectForKey:@"DataInfo"] objectForKey:@"UserInfo"];
        NSDictionary *xmlVodIndos = xmlDict[@"DataInfos"][@"DataInfo"][@"VodInfos"];
        NSLog(@"%@", xmlDict);
        userInfo = [[UserInfo alloc] initWithXMLDictionary:xmlUserInfo];
        NSInteger index = 0;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [vodInfos removeAllObjects];
        if ([xmlVodIndos[@"VodInfo"] isKindOfClass:[NSDictionary class]])
            [array addObject:xmlVodIndos[@"VodInfo"]];
        else
            array = xmlVodIndos[@"VodInfo"];
        for (index = 0; index < [array count]; index++) {
            NSDictionary *dict = array[index];
            VodInfo *info = [[VodInfo alloc] initWithXMLDictionary:dict];
            [vodInfos addObject:info];
        }
        [self performSelectorOnMainThread:@selector(endLoadData) withObject:nil waitUntilDone:NO];
        
    } failure:self.errorInfo];
}

-(void)endLoadData {
    [self.scrollView.header endRefreshing];
    [self refreshViews];
    [self reloadContentSize];

}

-(void)reloadContentSize {
    NSInteger showCount = [vodInfos count];
    NSInteger collectionViewLineCount = (showCount + 1) / 2 ;
    CGSize oldSize = self.collectionView.contentSize;
    CGSize newSize = oldSize;
    newSize.height = collectionViewLineCount * ([self collectionViewCellSize].height + 10);
    CGRect frame = self.collectionView.frame;
    frame.size = newSize;
    self.collectionView.contentSize = newSize;
    self.collectionView.frame = frame;
    self.collectionViewConstraintHeight.constant = newSize.height;
    newSize = self.scrollView.contentSize;
    newSize.height = frame.origin.y + frame.size.height;
    frame = self.scrollView.frame;
    frame.size = newSize;
//    self.scrollView.frame = frame;
    self.scrollView.contentSize = newSize;
  
    
}

-(void)refreshViews {
    self.nameLabel.text = userInfo.UserName;
    self.userLevel.text = userInfo.UserLevel;
    self.userMotto.text = userInfo.UserSignature;
    if(userInfo.UserHeadPic && ![userInfo.UserHeadPic isEqualToString:@""])
    {
        NSURL *url = [NSURL URLWithString:userInfo.UserHeadPic];
        [self.headImage setHidden:NO];
        [self.headImage sd_setImageWithURL:url placeholderImage:nil];
        
    }
    else
    {
        [self.headImage setHidden:YES];
        self.headImage.image = nil;
    }
    
    if ([userInfo.IsFocus isEqualToString:@"True"]) {
        self.attentionStatusButton.imageView.image = [UIImage imageNamed:@"add_gray.png"];
    }
    else if ([userInfo.IsFocus isEqualToString:@"False"])
    {
        self.attentionStatusButton.imageView.image = [UIImage imageNamed:@"add_gray2.png"];
    }
    
    self.attetionCount.text = userInfo.Focus;
    self.fansCount.text = userInfo.Fans;
    self.videoCount.text = [NSString stringWithFormat:@"%d",[vodInfos count]];
    
    CGFloat level = [userInfo.FaceLevel floatValue];
    CGFloat v = level / 5;
    [self.starRatingView setValue:v withAnimation:YES];
    
    [self.collectionView reloadData];
}

- (IBAction)back:(UIButton *)sender {
//    [ApplicationDelegate.manager.operationQueue cancelAllOperations];
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 刷新数据代码（开始）
- (void)setupHeader
{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.scrollView.header beginRefreshing];
}

#pragma mark 下拉刷新数据
- (void)loadNewData
{
    // 加载数据
    [self loadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
//    [self.scrollView.header endRefreshing];
}

#pragma mark 上拉刷新
- (void)setupFooter
{
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 忽略掉底部inset
    self.scrollView.footer.ignoredScrollViewContentInsetBottom = 0;
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    page++;
    // 1.添加假数据
    [self loadData];
    // 拿到当前的上拉刷新控件，结束刷新状态
//    [self.scrollView.footer endRefreshing];
}

// 刷新数据代码（结束）
//cell区域个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [vodInfos count];
}
//每区cell数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewCell ID] forIndexPath:indexPath];

    VodInfo *info = vodInfos[indexPath.row];
    [cell setImageWithURL:[NSURL URLWithString:info.LivePic]];
    [cell setTitle:info.LiveTitle];
    return cell;
}

-(CGSize)collectionViewCellSize {
    CGSize size = self.collectionView.frame.size;
    size.width -= 30;
    size.width *= 0.49;
    size.height = size.width * 1.5;
    
    return size;
}

//每个cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return [self collectionViewCellSize];
}
//cell是否可以被选中
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//cell被选中时的事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlayVideoViewController *playVideo = [[PlayVideoViewController alloc] init];
    Video *video = [[Video alloc] init];
    VodInfo *vodInfo = vodInfos[indexPath.row];
    video.clipId = vodInfo.ClipId;
    video.privacyType = vodInfo.PrivacyType;
    video.userId = userInfo.UserId;
    video.liveId = vodInfo.LiveId;
    playVideo.video = video;
//    self.navigationController.navigationBar.hidden = YES;
//    [self.navigationController pushViewController:playVideo animated:YES];
    playVideo.returnDelegate = self;
    [self presentViewController:playVideo animated:YES completion:nil];
}
- (IBAction)onAttentionTouchUpInside:(UIButton *)sender {
    
    [self.changeDelegete ChangeStatusWithId:userInfo.UserId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([userInfo.IsFocus isEqualToString:@"True"]) {
            userInfo.IsFocus = @"False";
        }
        else if ( [userInfo.IsFocus isEqualToString:@"False"])
        {
            userInfo.IsFocus = @"True";
        }
        [self refreshViews];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataShouldUpdate" object:nil];
    }];
//    [self loadNewData];
   
}

-(void)returnToLastViewController:(UIViewController *)viewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
