//
//  payViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/8/29.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "payViewController.h"
#import "alipayTableViewCell.h"
#import "alipayModel.h"
#import<CommonCrypto/CommonDigest.h>
@interface payViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *modelArr;
@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;

@property (nonatomic,strong)UITableView *tableViews;
@property (nonatomic, strong) BWHttpRequestManager *manager;

@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;

@end

@implementation payViewController

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
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title=@"充值产品列表";
    UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [popBtn setImage:[UIImage imageNamed:@"back32"] forState:UIControlStateNormal];
    [popBtn sizeToFit];
    [popBtn addTarget:self action:@selector(popClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBtn];

    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    self.tableViews=[[UITableView alloc]initWithFrame:CGRectMake(0, 0,HBScreenWidth,240) style:UITableViewStylePlain ];
    [self.tableViews registerNib:[UINib nibWithNibName:@"alipayTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"paycell"];
    self.tableViews.delegate=self;
    self.tableViews.dataSource=self;
    //tableView.backgroundColor=[UIColor clearColor];
    //分割线的颜色
    self.tableViews.separatorColor=[UIColor lightGrayColor];
    //分割线的样式
    self.tableViews.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    //分割线距离上,左,下,右的距离
    self.tableViews.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
    // 删除多余的cell
    [self.tableViews setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.tableViews.scrollEnabled=NO;
    [self.view addSubview:self.tableViews];
    
    [self setupCancelSuccess];
    [self getNet];
    

}


//返回的事件
- (void)popClick
{
    [self.dnsTask cancel];
    [self.csvTask cancel];
    [self.dataTask1 cancel];
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}



//网络请求
- (void)getNet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"正在加载中..."];
    });
    
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
  
//    parameter[@"yc_mobile_operator"] = @"中国电信";
//    parameter[@"yc_using_wifi"] = @"Y";
    parameter[@"action"] = @"query_recharge_product_list";
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
                            
                            alipayModel *model = [alipayModel mj_objectWithKeyValues:picDict];
                            [self.modelArr addObject:model];
                    }
                    
                    [self.tableViews reloadData];
               
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.modelArr.count;
    
}

//每行显示什么样的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    alipayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paycell"];
    if (!cell) {
        cell = [[alipayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"paycell"];
    }
    alipayModel *model=self.modelArr[indexPath.row];
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
    //支付宝
    if (indexPath.row==0) {
        
        [self  payOrden:indexPath.row];
       
    }

    
}


// md5
-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];//转换成utf-8
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        if ((result[i] & 0xFF)< 0x10) {
            
            [Mstr appendFormat:@"0"];
        }
        
        [Mstr appendFormat:@"%X",(result[i] & 0xFF)];
    }
    
    return Mstr;

}

//付款
- (void)payOrden:(NSInteger )row{
    
    [SVProgressHUD showWithStatus:@"创建订单中..."];
    alipayModel *model=self.modelArr[row];
    NSLog(@"%@",model.product_id);

    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
     parameter[@"trans_code"] = @"create_trade_info";
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    if(userMessage.user_account.length>0){
        
        parameter[@"yc_msisdn"] = userMessage.user_account_uid;
        parameter[@"msisdn"] =userMessage.user_account_uid;
        
    }
    
    NSDate *nowDate=[NSDate date];
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr=[formater stringFromDate:nowDate];
    NSString *time=[timeStr stringByAppendingString:@".300"];
    parameter[@"ptime"] =time;
    parameter[@"from_system"] =FromSystem;
    //@"18:DC:56:21:84:07"
    parameter[@"from_client_id"] =[McSystemMessageUtil getWifiMac];
    //parameter[@"from_client_id"] =@"18:DC:56:21:84:07";
    parameter[@"from_client_os"] =@"IOS";
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    parameter[@"from_client_version"] =version;
   // parameter[@"yc_mobile_operator"] =@"zhongguoyidong";
    parameter[@"yc_using_wifi"] =@"Y";
    parameter[@"from_client_desc"] =FromSystem;
    parameter[@"product_id"] = model.product_id;
    parameter[@"recharge_type"] = @"middle_ware";
   // parameter[@"from_client_os"] = model.product_id;
    
    NSLog(@"%@",parameter);
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        
        NSLog(@"%@",dict);
        NSLog(@"%@",dict[@"error_string"]);
        //失败
        if (dict[@"error_code"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
               // [SVProgressHUD showErrorWithStatus:dict[@"error_string"]];
                [SVProgressHUD dismiss];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
            });
            
           
        } else {  //成功,
            
           // NSMutableDictionary *josnDic = [NSMutableDictionary dictionary];
            NSDate *nowDate=[NSDate date];
            NSDateFormatter *formater=[[NSDateFormatter alloc]init];
            [formater setDateFormat:@"yyyyMMddhhmmss"];
            NSString *timeStrold=[formater stringFromDate:nowDate];
            NSString *timeStr=[timeStrold stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSLog(@"%@",timeStr);
            
            //请求列表
//            josnDic[@"ORDERNUMBER"] =@"xxx";
//            josnDic[@"ORDERPHONE"] =userMessage.user_account_uid;
//            josnDic[@"PAYTYPE"] =@"1";
//            josnDic[@"IPAY"] =@"1";
//            josnDic[@"MERCHANTURL"] =dict[@"notify_url"];
            NSInteger number=[model.recharge_fee integerValue];
            NSString *fee=[NSString stringWithFormat:@"%.2f",number/100.0];
//            josnDic[@"ORDERAMOUNT"] =fee;
//            josnDic[@"PRONAME"] =model.product_name;
//            josnDic[@"BACKDROPURL"] =dict[@"middle_ware_result_url"];
//            josnDic[@"ORDERSEQ"] =dict[@"trade_no"];
//            josnDic[@"ORDERNAME"] =@"校园中心";
//            josnDic[@"CLIENTNUMBER"] =dict[@"middle_ware_client_number"];
//            
            NSString *mac=[NSString stringWithFormat:@"ORDERSEQ=%@&ORDERDATE=%@&ORDERAMOUNT=%@&KEY=%@",dict[@"trade_no"],timeStr,fee,dict[@"middle_ware_client_key"]];
//        
//            josnDic[@"MAC"] =[self md5:mac];
//            josnDic[@"ORDERDATE"] =timeStr;
            __weak typeof(self) weakself = self;
            NSURL *url=[NSURL URLWithString:@"http://gzdxpay.mini189.cn/web/order-verify.action"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSString *str=[NSString stringWithFormat:@"CLIENTNUMBER=%@&ORDERSEQ=%@&PRONAME=%@&ORDERDATE=%@&ORDERAMOUNT=%@&MERCHANTURL=%@&BACKDROPURL=%@&ORDERNAME=school&ORDERPHONE=%@&ORDERNUMBER=xxx&CHANNEL=other&MAC=%@&PAYTYPE=1&IPAY=1",dict[@"middle_ware_client_number"],dict[@"trade_no"],model.product_name,timeStr,fee,dict[@"notify_url"],dict[@"middle_ware_result_url"],userMessage.user_account_uid,[self md5:mac]];
            
            NSLog(@"%@",str);
            
            request.HTTPBody =[str dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPMethod = @"POST";
            
            NSURLSession *session = [NSURLSession sharedSession];
            
            NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                    });
                    return;
                }
                
                
                NSString *contents=[[NSString alloc]init];
                contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
              NSMutableDictionary *DataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
               
                if ([DataDic[@"msg"] isEqualToString:@"failure"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                       //[SVProgressHUD showErrorWithStatus:DataDic[@"result"]];
                        [SVProgressHUD dismiss];
                        self.backgroundView.hidden=NO;
                        self.errorStringLabel.text=DataDic[@"result"];
                        
                    });
                   
                }
                if ([DataDic[@"msg"] isEqualToString:@"success"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [SVProgressHUD showErrorWithStatus:@"创建成功"];
                        
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:DataDic[@"result"]]];
                        
                    });
                    
                }
                
                
            }];
            [dnsTask resume];
            self.dnsTask=dnsTask;
            
        }
    }];
    
    
}


//注销成功界面布局
- (void)setupCancelSuccess
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
    
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, remindView.bw_width - 2 * 10, 40)];
    remindLabel.textColor = [UIColor blackColor];
    remindLabel.font = [UIFont systemFontOfSize:15];
    remindLabel.textAlignment=NSTextAlignmentCenter;
    remindLabel.numberOfLines=0;
    [remindView addSubview:remindLabel];
    self.errorStringLabel = remindLabel;
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(10, 80, remindView.bw_width - 2 * 10, 30);
    sureBtn.backgroundColor = HBConstColor;
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [remindView addSubview:sureBtn];
}
//温馨提示框上的确定按钮的点击事件
- (void)sureClick
{
    self.backgroundView.hidden = YES;
    
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
