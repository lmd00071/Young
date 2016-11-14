//
//  BWRewardAreaController.m
//  WidomStudy
//
//  Created by Sigbit on 16/4/15.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWRewardAreaController.h"

#import "BWRewardArea.h"

#import "BWRewardAreaCell.h"

@interface BWRewardAreaController ()

@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;

@property (nonatomic, strong) NSArray *rewardAreaArray;

@end

@implementation BWRewardAreaController

static NSString *rewardAreaCell = @"rewardAreaCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"兑奖区";
    
    self.tableView.backgroundColor = HBRGBColor(255, 255, 255, 1);
    self.tableView.rowHeight = 67;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"BWRewardAreaCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:rewardAreaCell];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_refresh"] forState:UIControlStateNormal];
    [rightBtn sizeToFit];
    [rightBtn addTarget:self action:@selector(setupHttpRequest) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HBScreenWidth, 1)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    [self setupData];
}

#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 3;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewardAreaArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BWRewardAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:rewardAreaCell];
    
    BWRewardArea *model = self.rewardAreaArray[indexPath.row];
    
    cell.rewardArea = model;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - 网络请求
- (void)setupHttpRequest
{
    
    
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
    parameter[@"action"] = @"show_exchange_rule_list";
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    if(userMessage.user_account.length>0){
        
        parameter[@"yc_msisdn"] = userMessage.user_account_uid;
        
    }
    
    NSString *xmlString=[[NSString alloc]init];
    xmlString = [parameter newXMLString];
    
    NSURL *url=[NSURL URLWithString:BWBaseUrlString];
    NSMutableURLRequest *dnsRequest = [NSMutableURLRequest requestWithURL:url];
    
    [dnsRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    dnsRequest.HTTPBody = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    dnsRequest.HTTPMethod = @"POST";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    __weak typeof(self) weakself = self;
    
    //拿到dns服务器的请求
    NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:dnsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
            return;
        }
        NSDictionary *dnsDict = [NSDictionary dictionaryWithXMLData:data];
        
        NSMutableURLRequest *csvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsDict[@"dns.url"]]];
        [csvRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSStringToBetyArray *tool=[[NSStringToBetyArray alloc]init];
        csvRequest.HTTPBody = [tool encryptString:xmlString];
        csvRequest.HTTPMethod = @"POST";
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSURLSessionDataTask *csvTask = [session dataTaskWithRequest:csvRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (error) {
                    [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                    return;
                }
                
                NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakself setupDatabaseWithCsvDict:dataDict];
                    [weakself.tableView reloadData];
                    [SVProgressHUD dismiss];
                });
            }];
            [csvTask resume];
            weakself.csvTask = csvTask;
        });
    }];
    [dnsTask resume];
    self.dnsTask = dnsTask;
}

//根据请求到的csv地址进行数据处理
- (void)setupDatabaseWithCsvDict:(NSDictionary *)csvDict
{
    NSString *action = @"show_exchange_rule_list";
    NSString *action_parameter = @"show_exchange_rule_list";
    NSString *selectString = [NSString stringWithFormat:@"SELECT * FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, action_parameter];
    NSArray *overModelArray = [BWCSVDatabase queryData:selectString];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (BWCSVModel *csvModel in overModelArray) {
        
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
        [manager removeItemAtPath:csvPath error:nil];
    }
    
    NSString *deleteData = [NSString stringWithFormat:@"DELETE FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, action_parameter];
    [BWCSVDatabase deleteData:deleteData];
    
    NSArray *csvModelArray = [BWCSVDatabase writeCsvWithCsvDict:csvDict action:action action_parameter:action_parameter];
    for (BWCSVModel *csvModel in csvModelArray) {
        
        //插入数据
        [BWCSVDatabase insertModal:csvModel];
        
        if ([csvModel.csvType isEqualToString:BWDataCsvKey]) {
            
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
            NSString *dataString = [NSString stringWithContentsOfFile:csvPath encoding:NSUTF8StringEncoding error:nil];
            NSArray *dataArray = [dataString csvStringTransformToDictionary];
            NSMutableArray *modelArray = [NSMutableArray array];
            for (NSDictionary *dataDict in dataArray) {
                BWRewardArea *model = [BWRewardArea mj_objectWithKeyValues:dataDict];
                [modelArray addObject:model];
            }
            self.rewardAreaArray = modelArray;
        }
    }
}

//进行数据获取
- (void)setupData
{
    NSString *action = @"show_exchange_rule_list";
    NSString *action_parameter = @"show_exchange_rule_list";
    NSString *selectString = [NSString stringWithFormat:@"SELECT * FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, action_parameter];
    NSArray *csvModelArray = [BWCSVDatabase queryData:selectString];
    if (csvModelArray.count > 0) {
        
        //先将数据显示出来,然后进行判断
        for (BWCSVModel *csvModel in csvModelArray) {
            
            if ([csvModel.csvType isEqualToString:BWDataCsvKey]) {    //数据csv对应的模型
                NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
                NSString *dataString = [NSString stringWithContentsOfFile:csvPath encoding:NSUTF8StringEncoding error:nil];
                NSArray *dataArray = [dataString csvStringTransformToDictionary];
                NSMutableArray *modelArray = [NSMutableArray array];
                for (NSDictionary *dataDict in dataArray) {
                    BWRewardArea *model = [BWRewardArea mj_objectWithKeyValues:dataDict];
                    [modelArray addObject:model];
                }
                self.rewardAreaArray = modelArray;
            }
        }
        BWCSVModel *model = csvModelArray.firstObject;
        if ([NSDate isLaterTimeThanNowWithDateString:model.overdueTime]) {    //未超时,直接赋值
            
        } else {    //超过存储时间,进行请求
            [self setupHttpRequest];
        }
        
    } else {
        [self setupHttpRequest];
    }
}

@end
