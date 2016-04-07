//
//  FansTableViewCell.m
//  tv_shop
//
//  Created by mac on 15/10/24.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "FansTableViewCell.h"
#import "Fans.h"
#import "UIImageView+WebCache.h"
#import "Attentions.h"
#import "XMLReader.h"

@implementation FansTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeStatus:(UIButton *)sender {
    [self.changeDelegete ChangeStatusWithId:self.userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        NSError *error = nil;
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLParse:parser options:0 error:&error];
        NSLog(@"%@", xmlDict);
        
        NSString *isFocus = xmlDict[@"DataInfos"][@"DataInfo"][@"IsFocus"][@"text"];
        if (isFocus) {
            if ([isFocus isEqualToString:@"True"]) {
                if ([self.data class] == [Fans class]) {
                    Fans *fans = (Fans *)self.data;
                    fans.isAttetion = isFocus;
                    [self setFans:fans];
                }
                else {
                    [self.attentionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
                    [self.attentionBtn setBackgroundColor:[MyColor colorWithHexString:@"d9d3d3" alpha:1.0]];
                }
            }
            else if ([isFocus isEqualToString:@"False"]){
                if ([self.data class] == [Fans class]) {
                    Fans *fans = (Fans *)self.data;
                    fans.isAttetion = isFocus;
                    [self setFans:fans];
                }
                else {
                    [self.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
                    [self.attentionBtn setBackgroundColor:[MyColor colorWithHexString:@"F75B5F" alpha:1.0]];
                }
            }
        }
        /*
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
            NSArray *datas = [dic objectForKey:@"DataInfos"];
            NSString *isTrue = [NSString stringWithFormat:@"%@",[[datas objectAtIndex:0] objectForKey:@"IsFocus"]];
            if (datas.count!=0) {
                if ([self.tag isEqualToString:@"FANS"]) {
                    for (NSInteger i=0; i<userDatas.count; i++) {
                        Fans *data = [userDatas objectAtIndex:i];
                        if ([data.userId isEqualToString:attentionId]) {
                            data.isAttetion = isTrue;
                            [self.tabBarController.tabBar setTag:1];//用来判断回到首页是否要刷新
                        }
                    }
                }else if ([self.tag isEqualToString:@"ATTENTION"]){
                    for (NSInteger i=0; i<userDatas.count; i++) {
                        Attentions *data = [userDatas objectAtIndex:i];
                        if ([data.userId isEqualToString:attentionId]) {
                            [userDatas removeObjectAtIndex:i];
                            [self.tabBarController.tabBar setTag:1];//用来判断回到首页是否要刷新
                        }
                    }
                }
            }
            
            
            [self.tableView reloadData];
        }
         */
    }];
}

+(NSString *)ID{
    return @"MYFANS";
}

-(void)setCellValue:(id)data{
    if ([data class]==[Fans class]) {
        Fans *fans = data;
        [self setFans:fans];
    }else{
        Attentions *attention = data;
        [self setAttention:attention];
    }
}

-(void)setFans:(Fans*)fans{
    NSMutableString *equalStr = [[NSMutableString alloc] initWithString:@"True"];
    if ([fans.isAttetion isEqualToString:equalStr]) {
        [self.attentionBtn setEnabled:NO];
        [self.attentionBtn setTitle:@"相互关注" forState:UIControlStateDisabled];
        [self.attentionBtn setBackgroundColor:[MyColor colorWithHexString:@"d9d3d3" alpha:1.0]];
    }else{
        [self.attentionBtn setEnabled:YES];
        [self.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.attentionBtn setBackgroundColor:[MyColor colorWithHexString:@"F75B5F" alpha:1.0]];
    }
    NSURL *url = [NSURL URLWithString:fans.userPic];
    [self.headPic sd_setImageWithURL:url];
    [self.userName setText:fans.userName];
    [self.userMotto setText:fans.userMotto];
    if ([fans.userSex isEqual:@"男"]) {
        [self.userSex setImage:[UIImage imageNamed:@"boy_icon.png"]];
    }else if ([fans.userSex isEqual:@"女"]){
        [self.userSex setImage:[UIImage imageNamed:@"girl_icon.png"]];
    }
    self.userId = fans.userId;
}
-(void)setAttention:(Attentions*)attention{
    [self.attentionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    [self.attentionBtn setBackgroundColor:[MyColor colorWithHexString:@"d9d3d3" alpha:1.0]];
    NSURL *url = [NSURL URLWithString:attention.userPic];
    [self.headPic sd_setImageWithURL:url];
    [self.userName setText:attention.userName];
    [self.userMotto setText:attention.userMotto];
    if ([attention.userSex isEqual:@"男"]) {
        [self.userSex setImage:[UIImage imageNamed:@"boy_icon.png"]];
    }else if ([attention.userSex isEqual:@"女"]){
        [self.userSex setImage:[UIImage imageNamed:@"girl_icon.png"]];
    }
    self.userId = attention.userId;
}

@end
