//
//  DownViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/8/16.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "DownViewController.h"
#import "DownTableViewCell.h"
#import "DownDodel.h"
@interface DownViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *modelArr;
@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;

@end
static NSString *downcell=@"DOWNCELL";
@implementation DownViewController

- (NSMutableArray *)modelArr
{
    if (_modelArr == nil) {
        
        self.modelArr = [NSMutableArray array];
    }
    return _modelArr;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置成导航栏下面开始计算
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=HBRGBColor(230, 231, 233, 1);
    self.navigationItem.title=@"下载";
    //设置成导航栏下面开始计算
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DownTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:downcell];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
//    self.tableView.scrollEnabled=NO;
    
    [self httpGet];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.modelArr.count;
    
    
}

//每行显示什么样的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:downcell];
    if (!cell) {
        cell = [[DownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:downcell];
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    DownDodel *model=self.modelArr[indexPath.row];
//    model.app_name=@"易信";
//    model.downloaded_tips=@"已有340人完成";
//    model.reward_yp=@"10";
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
    return 80;
    
}


//cell的点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DownDodel *model=self.modelArr[indexPath.row];
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",
                     model.apple_app_sid ];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    
}

- (void)httpGet
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
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    if(userMessage.user_account.length>0){
        
        parameter[@"yc_msisdn"] = userMessage.user_account_uid;
        
    }
    parameter[@"action"] = @"appd_get_app_list";
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
            
            NSDictionary *dict = [NSDictionary dictionaryWithXMLData:data];
            
            if (dict[@"error_code"]) {
                
                [SVProgressHUD showErrorWithStatus:dict[@"error_string"]];
            } else {  //成功,
                
                //非UTF-8编码
                NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                
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
                    
                    [SVProgressHUD dismiss];
                    
                    for (NSMutableDictionary *picDict in picArray) {
                        
                        DownDodel *model = [DownDodel mj_objectWithKeyValues:picDict];
                        [self.modelArr addObject:model];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        [self.tableView reloadData];
                        
                    });
                }];
                
                [dataTask1 resume];
                weakself.dataTask1 = dataTask1;
            }
        }];
        [csvTask resume];
        weakself.csvTask = csvTask;
        
        
    }];
    [dnsTask resume];
    self.dnsTask=dnsTask;
    
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
