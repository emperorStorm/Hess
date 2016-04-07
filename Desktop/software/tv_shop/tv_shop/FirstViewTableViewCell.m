//
//  FirstViewTableViewCell.m
//  tv_shop
//
//  Created by mac on 15/10/15.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "FirstViewTableViewCell.h"
#import "FirstViewController.h"
#import "LoginViewController.h"
#import "XMLReader.h"

@implementation FirstViewTableViewCell
{
    UIImage *addImg;
}

- (void)awakeFromNib {
    // Initialization code
    [self.roomPic.layer setMasksToBounds:YES];
    [self.roomPic.layer setCornerRadius:25];
    [self.userHeadView.layer setBorderWidth:4];
    [self.userHeadView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.userHeadView.layer setMasksToBounds:YES];
    [self.userHeadView.layer setCornerRadius:35];
    [self.userHeadView setBackgroundColor:[UIColor grayColor]];
    
    [self.isLiveTag.layer setBorderWidth:1];
    [self.isLiveTag.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.isLiveTag.layer setMasksToBounds:YES];
    [self.isLiveTag.layer setCornerRadius:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)ID{
    return @"FirstViewTableViewCell";
}

- (void)setValueWithRoom:(TVRoom *)room{
    self.room = room;
    if ([self.room.isLive isEqualToString:@"1"]) {
        [self.isLiveTag setText:@"直播"];
    }else{
        [self.isLiveTag setText:@"replay"];
    }
    self.roomName.text = room.roomName;
    NSURL *picUrl = [NSURL URLWithString:room.roomPic];
    NSLog(@"图片  %@",room.roomPic);
    [self.roomPic sd_setImageWithURL:picUrl placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"直播封面加载错误：%@",error);
    }];
    
    self.liveName.text = room.liveTitle;
    NSURL *liveUrl = [NSURL URLWithString:room.livePic];
    [self.livePic sd_setImageWithURL:liveUrl];
    self.livePic.contentMode = UIViewContentModeScaleToFill;
    self.timeLabel.text = room.liveTime;
    self.viewerCount.text = room.viewerCount;
    self.addressLabel.text = room.userAddr;
    
    self.userName.text = room.userName;
//    NSLog(@"====头像%@",room.userPic);
    NSURL *userHead = [NSURL URLWithString:room.userPic];
    if (self.userHeadPic == nil) {
        self.userHeadPic = [[UIImageView alloc] init];
    }
    CGFloat witdh = 70 * 4 / 3.0;
    CGFloat height = 70;
    self.userHeadPic.frame = CGRectMake(- (witdh - height)/ 2, 0, witdh, height);
    [self.userHeadView addSubview:self.userHeadPic];
    [self.userHeadPic sd_setImageWithURL:userHead placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"主播头像加载错误：%@",error);
        CGSize picSize = self.userHeadPic.image.size;
        if (picSize.height > 0 && picSize.width > 0) {
            if ( picSize.width > picSize.height) {
                CGFloat witdh = 70 * picSize.width / picSize.height;
                CGFloat height = 70;
                self.userHeadPic.frame = CGRectMake((height - witdh) / 2, 0, witdh, height);
            }else {
                CGFloat witdh = 70 ;
                CGFloat height = 70 * picSize.height / picSize.width;
                self.userHeadPic.frame = CGRectMake(0, (witdh - height) / 2, witdh, height);
            }
        }
    }];
//    self.userId = room.userId;
//    NSMutableString *equalStr = [[NSMutableString alloc] initWithString:@"True"];
    if (([room.userId isEqual:[LocalUser getId]])) {
//        self.attentionBtn.hidden = YES;
        [self.attentionBtn setHidden:YES];
    }
    else {
        [self.attentionBtn setHidden:NO];
    }
    if (addImg == nil) {
        addImg = [UIImage imageNamed:@"add.png"];
    }
    if ([self.room.isAttetion isEqualToString:@"True"]) {
        self.attentionBtn.layer.cornerRadius = 3;
        addImg = self.attentionBtn.imageView.image;
        [self.attentionBtn setImage:nil forState:UIControlStateNormal];
        self.attentionBtn.backgroundColor = [MyColor colorWithHexString:@"EA414C" alpha:1.0];
        self.attentionBtn.titleLabel.textColor = [UIColor whiteColor];
        [self.attentionBtn setTitle:@"取消关注" forState: UIControlStateNormal];
    }
    else {
        self.attentionBtn.layer.cornerRadius = 3;
        [self.attentionBtn setImage:addImg forState:UIControlStateNormal];
        self.attentionBtn.backgroundColor = [UIColor whiteColor];
        [self.attentionBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

- (IBAction)addAttention:(UIButton *)sender {
//    NSLog(@"主播id %@",self.userId);
    [self changeStatus:self.userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        
        NSError *error = nil;
        
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
        
        NSString *isFocus = xmlDict[@"DataInfos"][@"DataInfo"][@"IsFocus"][@"text"];
        if (isFocus) {
            self.room.isAttetion = isFocus;
            FirstViewController *viewController = (FirstViewController *)self.viewController;
            if ([isFocus isEqualToString:@"True"]) {
                self.attentionBtn.layer.cornerRadius = 3;
                addImg = self.attentionBtn.imageView.image;
                [self.attentionBtn setImage:nil forState:UIControlStateNormal];
                self.attentionBtn.backgroundColor = [MyColor colorWithHexString:@"EA414C" alpha:1.0];
                self.attentionBtn.titleLabel.textColor = [UIColor whiteColor];
                [self.attentionBtn setTitle:@"取消关注" forState: UIControlStateNormal];
                
                [viewController performSelectorOnMainThread:@selector(showText:) withObject:@"关注成功" waitUntilDone:NO];
            }
            else if ([isFocus isEqualToString:@"False"] ){
                
                self.attentionBtn.layer.cornerRadius = 3;
                [self.attentionBtn setImage:addImg forState:UIControlStateNormal];
                self.attentionBtn.backgroundColor = [UIColor whiteColor];
                [self.attentionBtn setTitle:@"" forState:UIControlStateNormal];
                [viewController performSelectorOnMainThread:@selector(showText:) withObject:@"已取消关注" waitUntilDone:NO];
            }
        }
    }];
}

- (void)changeStatus:(NSString *)attentionId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
{
    if ([LocalUser isUserExist]) {
        // 返回的数据格式是XML
        ApplicationDelegate.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"AddFocus" forKey:@"action"];
        [dict setObject:[LocalUser getSession] forKey:@"SessionKey"];
        [dict setObject:attentionId forKey:@"UserId"];
        // 网络访问是异步的,回调是主线程的,因此程序员不用管在主线程更新UI的事情
        [ApplicationDelegate.manager GET:@"wap/PowerClient.aspx" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation, responseObject);
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            NSLog(@"%@", error);
        }];
    }
    else{
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.viewController.navigationController pushViewController:login animated:YES];
    }
}

@end
