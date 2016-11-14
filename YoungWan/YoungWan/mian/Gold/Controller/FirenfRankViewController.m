//
//  FirenfRankViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/10/8.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "FirenfRankViewController.h"
#import "FrienfRankTableViewCell.h"
#import "firendRankMmodel.h"
#import "friendAttModel.h"
#import "UIImageView+WebCache.h"
@interface FirenfRankViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *modelArr;
@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;

@property (nonatomic, strong) BWHttpRequestManager *manager;

@property (strong, nonatomic) IBOutlet UIImageView *titleImageView;

@property (strong, nonatomic) IBOutlet UITableView *tableViews;

@property (nonatomic, strong)  friendAttModel *attModel;
@end

@implementation FirenfRankViewController


- (NSMutableArray *)modelArr
{
    if (_modelArr == nil) {
        
        self.modelArr = [NSMutableArray array];
    }
    return _modelArr;
}

- (BWHttpRequestManager *)manager
{
    if (_manager == nil) {
        BWHttpRequestManager *manager = [[BWHttpRequestManager alloc] init];
        _manager = manager;
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableViews registerNib:[UINib nibWithNibName:@"FrienfRankTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Rankcell"];
    //分割线的颜色
    self.tableViews.separatorColor=[UIColor lightGrayColor];
    //分割线的样式
    self.tableViews.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    // 删除多余的cell
    [self.tableViews setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.tableViews.scrollEnabled=NO;
     self.attModel = [[friendAttModel alloc]init];
    [self http];
}

//读取通讯录的方法
- (IBAction)read_address:(UIButton *)sender {
    
    
    
    
}


- (void)http{

    [SVProgressHUD showWithStatus:@"正在加载中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"ui_show";
    NSDate *nowDate=[NSDate date];
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr=[formater stringFromDate:nowDate];
    NSString *time=[timeStr stringByAppendingString:@".300"];
    parameter[@"ptime"] =time;
    parameter[@"from_system"] =FromSystem;
    //@"18:DC:56:21:84:07"
    parameter[@"from_client_id"] =[McSystemMessageUtil getWifiMac];
    parameter[@"from_client_os"] =@"IOS";
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    parameter[@"from_client_version"] =version;
    parameter[@"from_client_desc"] =FromSystem;
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    if(userMessage.user_account.length>0){
        
        parameter[@"yc_msisdn"] = userMessage.user_account_uid;
        
    }
    
    parameter[@"action"] = @"buddy_rank_yp_query";
    parameter[@"action_parameter"] = @"";
    
    NSString *xmlString = [parameter newXMLString];
    
    __weak typeof(self) weakself = self;
    NSURL *url=[NSURL URLWithString:BWBaseUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
            });
            return;
        }
        
        NSDictionary *dnsDict = [NSDictionary dictionaryWithXMLData:data];
        
        NSMutableURLRequest *dnsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsDict[@"dns.url"]]];
        
        [dnsRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSStringToBetyArray *tool=[[NSStringToBetyArray alloc]init];
        dnsRequest.HTTPBody = [tool encryptString:xmlString];
        dnsRequest.HTTPMethod = @"POST";
        
        NSURLSessionDataTask *csvTask = [session dataTaskWithRequest:dnsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                });
                return;
            }
            
            NSDictionary *dict = [NSDictionary dictionaryWithXMLData:data];
            
            if (dict[@"error_code"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:dict[@"error_string"]];
                });
                
            } else {  //成功,
                
                //非UTF-8编码
                NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_t group = dispatch_group_create();
                
                
                dispatch_group_async(group, queue, ^{
                    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:dict[@"template_attr_csv"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                            });
                            return;
                        }
                        //回到主线程刷新数据
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *contents = [[NSString alloc] initWithData:data encoding:encode];
                        if (contents == nil || contents.length <= 0) {
                            return;
                        }
                        NSArray *newsArray = [contents csvStringTransformToDictionary];
                        //self.attModel=nil;
                        if (newsArray != nil && newsArray.count > 0) {
                            NSMutableDictionary *newsDict = [NSMutableDictionary dictionary];
                            for (NSDictionary *dict in newsArray) {
                                
                                if ([dict[@"key"] isEqualToString:@"标题"]) {
                                    newsDict[@"title"] = dict[@"value"];
                                    
                                }
                                if ([dict[@"key"] isEqualToString:@"广告图"]) {
                                    newsDict[@"advertisement"] = dict[@"value"];
                                    
                                }
                                if ([dict[@"key"] isEqualToString:@"邀请提示"]) {
                                    newsDict[@"Messager"] = dict[@"value"];
                                    
                                }
                                
                            }
                            [self.attModel setValuesForKeysWithDictionary:newsDict];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:self.attModel.advertisement] placeholderImage:[UIImage imageNamed:@""]];
                            });
                            
                        }
                        
                    }];
                    [dataTask resume];
                    weakself.dataTask = dataTask;
                    
                    
                });
                
                dispatch_group_async(group, queue, ^{
                    
                NSURLSessionDataTask *dataTask1 = [session dataTaskWithURL:[NSURL URLWithString:dict[@"template_data_csv"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                        });
                        return;
                    }
                    //清楚上次的数组
                    [weakself.modelArr removeAllObjects];
                    NSString *contents = [[NSString alloc] initWithData:data encoding:encode];
                    
                    NSArray *picArray = [contents csvStringTransformToDictionary];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        
                        for (NSMutableDictionary *picDict in picArray) {
                            
                            firendRankMmodel *model = [firendRankMmodel mj_objectWithKeyValues:picDict];
                            [self.modelArr addObject:model];
                        }
                        
                        [self.tableViews reloadData];
                        
                    });
                }];
                
                [dataTask1 resume];
                weakself.dataTask1 = dataTask1;
                
             });
            }
        }];
        [csvTask resume];
        weakself.csvTask = csvTask;
        
        
    }];
    [dnsTask resume];
    self.dnsTask=dnsTask;



}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.modelArr.count;
    
}

//每行显示什么样的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FrienfRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rankcell"];
    if (!cell) {
        cell = [[FrienfRankTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Rankcell"];
    }
    firendRankMmodel *model=self.modelArr[indexPath.row];
    if (self.modelArr.count==1) {
        cell.Isone=YES;
    }else{
        cell.Isone=NO;
    }
    [cell getmodel:model];
    return cell;
}


//几个分区
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}



//每一行的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
    
}


//cell的点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //支付宝
    
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

@end
