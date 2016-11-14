//
//  BWRewardHistoryController.m
//  WidomStudy
//
//  Created by Sigbit on 16/4/15.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWRewardHistoryController.h"

#import "BWRewardHistory.h"

#import "BWRewardHistoryCell.h"

@interface BWRewardHistoryController ()

@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;

@property (nonatomic, strong) NSArray *rewardHistoryArray;

@property (nonatomic, weak) UIView *backgroundView;

@end

@implementation BWRewardHistoryController

static NSString *rewardHistoryCell = @"rewardHistoryCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"兑奖历史";
    
    self.tableView.rowHeight = 67;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"BWRewardHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:rewardHistoryCell];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_refresh"] forState:UIControlStateNormal];
    [rightBtn sizeToFit];
    [rightBtn addTarget:self action:@selector(setupHttpRequest) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HBScreenWidth, 1)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    [self setupNoHistory];
    
    [self setupData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewardHistoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BWRewardHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:rewardHistoryCell];
    
    BWRewardHistory *model = self.rewardHistoryArray[indexPath.row];
    
    cell.rewardHistory = model;
    
    return cell;
}

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
    parameter[@"action"] = @"exchange_self_history";
    
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
    NSString *action = @"exchange_self_history";
    NSString *action_parameter = @"exchange_self_history";
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
            if (dataArray.count == 0) {
                self.backgroundView.hidden = NO;
            }
            NSMutableArray *modelArray = [NSMutableArray array];
            for (NSDictionary *dataDict in dataArray) {
                BWRewardHistory *model = [BWRewardHistory mj_objectWithKeyValues:dataDict];
                [modelArray addObject:model];
            }
            self.rewardHistoryArray = modelArray;
        }
    }
}

//进行数据获取
- (void)setupData
{
    NSString *action = @"exchange_self_history";
    NSString *action_parameter = @"exchange_self_history";
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
                if (dataArray.count == 0) {
                    self.backgroundView.hidden = NO;
                }
                NSMutableArray *modelArray = [NSMutableArray array];
                for (NSDictionary *dataDict in dataArray) {
                    BWRewardHistory *model = [BWRewardHistory mj_objectWithKeyValues:dataDict];
                    [modelArray addObject:model];
                }
                self.rewardHistoryArray = modelArray;
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

- (void)setupNoHistory
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:backgroundView];
    backgroundView.hidden = YES;
    self.backgroundView = backgroundView;
    
    UIView *remindView = [[UIView alloc] init];
    remindView.bw_width = HBScreenWidth - 60;
    remindView.bw_height = 120;
    remindView.center = CGPointMake(HBScreenWidth * 0.5, HBScreenHeight * 0.5);
    remindView.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:remindView];
    
    UILabel *warmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, remindView.bw_width, 40)];
    warmLabel.text = @"温馨提示";
    warmLabel.font = [UIFont systemFontOfSize:20];
    warmLabel.textColor = [UIColor whiteColor];
    warmLabel.backgroundColor = HBConstColor;
    warmLabel.textAlignment = NSTextAlignmentCenter;
    [remindView addSubview:warmLabel];
    
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(BWMargin, 40, remindView.bw_width - 2 * BWMargin, 40)];
    remindLabel.textColor = [UIColor blackColor];
    remindLabel.font = [UIFont systemFontOfSize:15];
    remindLabel.numberOfLines = 0;
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.text = @"您还没有兑过奖哦";
    [remindLabel sizeToFit];
    [remindView addSubview:remindLabel];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(BWMargin, 80, remindView.bw_width - 2 * BWMargin, 30);
    [sureBtn setBackgroundColor:HBConstColor];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [remindView addSubview:sureBtn];
}

- (void)sureClick
{
    self.backgroundView.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
