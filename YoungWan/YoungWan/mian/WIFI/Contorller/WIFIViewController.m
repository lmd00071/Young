//
//  WIFIViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/11.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "WIFIViewController.h"
#import "payViewController.h"
#import "WIFImodel.h"
#import "RuleViewController.h"
#import "UIImageView+WebCache.h"
#import "TestNetViewController.h"
#import "LoginViewController.h"
#import "RegisterANDForginViewController.h"
@interface WIFIViewController ()<UIScrollViewDelegate,UIWebViewDelegate>

@property (nonatomic, strong) NSArray *upbtnArray;
@property (nonatomic, strong) NSArray *toolbtnArray;

//自己的详情
@property (nonatomic,strong)UILabel *userLabel;
//显示时间

//时间
@property (nonatomic,strong)UILabel *timeLabel;
//wifi
@property (nonatomic,strong)UILabel *wifiLabel;
//上线
@property (nonatomic,strong)UIButton *upButton;

//标题的图片
@property (nonatomic,strong)UIImageView *titleImageView;

@property (nonatomic,strong)NSMutableArray *modelArr;
@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;

//上线下线
@property (nonatomic,strong)NSString *UpUrlStr;
@property (nonatomic,strong)NSString *DownUrlStr;
@property (nonatomic,strong)NSString *requestIpStr;
@property (nonatomic,strong)NSString *userIpStr;

@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)UIWebView *webView_test;
@property (nonatomic,strong)UIWebView *webView_down;
@property (nonatomic,strong)NSMutableDictionary *jsDic;

@property (nonatomic, strong) BWHttpRequestManager *manager;

//定时器
@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,assign)NSInteger time;
@end

@implementation WIFIViewController


- (NSMutableDictionary *)jsDic
{
    if (_jsDic == nil) {
        
        self.jsDic = [[NSMutableDictionary alloc]init];
    }
    return _jsDic;
}

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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.webView = [[UIWebView alloc]init];
    self.webView.delegate=self;
    [self.view addSubview:self.webView];
    self.webView_test = [[UIWebView alloc]init];
    self.webView_test.delegate=self;
    [self.view addSubview:self.webView_test];
    self.webView_down = [[UIWebView alloc]init];
    self.webView_down.delegate=self;
    [self.view addSubview:self.webView_down];
    
    //设置成导航栏下面开始计算
    self.navigationController.navigationBar.translucent = NO;
    //是否登录了
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    
    if(userMessage.user_account.length>0){
    
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@,欢迎您",userMessage.user_account_uid]];
        [str addAttribute:NSForegroundColorAttributeName value:HBRGBColor(54, 151, 202, 1) range:NSMakeRange(0,11)];
        self.userLabel.attributedText = str;
        
        //登录了
        //是否为wifi环境
        if ([McSystemMessageUtil  netEnvironmentIsWifi]) {
            //是否包含YOUNG的wifi
            NSString *wifiName=[McSystemMessageUtil getWifiName];
            if ([wifiName containsString:@"YOUNG"]) {
                
                    if ([self.wifiLabel.text isEqualToString:@"正在认证上线..."]) {
                        
                        [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
                        self.upButton.backgroundColor=[UIColor lightGrayColor];
                        self.timeLabel.hidden=NO;
                        return;
                        
                    }
                    if ([self.upButton.titleLabel.text isEqualToString:@"下线"]) {
                        
                        [self.upButton setTitle:@"下线" forState:UIControlStateNormal];
                        self.upButton.backgroundColor=[UIColor redColor];
                        self.timeLabel.hidden=YES;
                        return;
                    }
                    
                    self.wifiLabel.text=@"您还未上线,请点击上线按钮";
                    [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
                    self.upButton.backgroundColor=[UIColor orangeColor];
                    self.timeLabel.hidden=NO;
             
                
            }else{
                
                //登录了连接wifi了, 但是没有连接YOUNG的wifi
                self.wifiLabel.text=@"您还未连接名称为\"YOUNG\"的WIFI,请先连接";
                [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
                self.upButton.backgroundColor=[UIColor orangeColor];
                self.timeLabel.hidden=NO;
            }
            
        }else{
            
            //登录了没有连接wifi
            self.wifiLabel.text=@"您在用蜂窝移动网络,请切换到\"YOUNG\"的WIFI";
            [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
            self.upButton.backgroundColor=[UIColor orangeColor];
            self.timeLabel.hidden=NO;
        }
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
        parameter[@"trans_code"] = @"query_internet_remaining_time";
        NSDate *nowDate=[NSDate date];
        NSDateFormatter *formater=[[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr=[formater stringFromDate:nowDate];
        NSString *time=[timeStr stringByAppendingString:@".300"];
        parameter[@"ptime"] =time;
        parameter[@"from_system"] =FromSystem;
        //@"18:DC:56:21:84:07"
        parameter[@"from_client_id"] =[McSystemMessageUtil getWifiMac];
        parameter[@"from_client_os"] =@"iOS";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        parameter[@"from_client_version"] =version;
        parameter[@"from_client_desc"] =FromSystem;
        parameter[@"user_account"] = userMessage.user_account;
     
        __weak typeof(self) weakself = self;
        [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
            //失败
            if (dict[@"error_code"]) {
                return ;
            } else {  //成功,
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *usertime=dict[@"remaining_time"];
                    NSInteger Stime=[usertime integerValue];
                    NSInteger Hour=Stime/3600;
                    NSInteger min=(Stime-Hour*3600)/60;
                    NSString *hourStr;
                    NSString *minStr;
                    
                    if (Hour==0) {
                        hourStr=@"00";
                    }else{
                        hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
                    }
                    if (min==0) {
                        minStr=@"00";
                    }else{
                        minStr=[NSString stringWithFormat:@"%ld",(long)min];
                    }
                    NSInteger hourlength=hourStr.length;
                    NSInteger minlength=minStr.length;
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@:%@",hourStr,minStr]];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(5,hourlength+minlength+1)];
                    self.timeLabel.attributedText = str;
                    
                    
                });

            }
        }];

    }else{
        
        //没有登录
        [self.upButton setTitle:@"登录" forState:UIControlStateNormal];
        self.upButton.backgroundColor=[UIColor orangeColor];
        self.wifiLabel.text=@"使用YOUNG网络客户端,尽早免费WiFi";
        self.userLabel.text=@"您还未登录,请点击登录按钮";
        self.timeLabel.hidden=YES;
    }


    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.timer setFireDate:[NSDate distantFuture]];

   

}
- (void)viewWillDisappear:(BOOL)animated
{
     [SVProgressHUD dismiss];
     [self.webView removeFromSuperview];
     [self.webView_test removeFromSuperview];
     [self.webView_down removeFromSuperview];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor=HBRGBColor(230, 231, 233, 1);
    self.navigationItem.title=@"YOUNG网络";
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
    //注册退出登录
    NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(recieveNotification:) name:@"outlogin" object:nil];
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [self setWIFI];
    [self httpGet];
    
   
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
    
    parameter[@"action"] = @"show_home_page";
    parameter[@"action_parameter"] = @"layout_id=wifi";
    
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
                
                    
                        
                        for (NSMutableDictionary *picDict in picArray) {
                            
                            WIFImodel *model = [WIFImodel mj_objectWithKeyValues:picDict];
                            [self.modelArr addObject:model];
                        }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        WIFImodel *model=self.modelArr[0];
                        [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"ad_bar1.jpg"]];
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

//布局WIFI页面
- (void)setWIFI
{
    //正页面的滚动
    UIScrollView *scrolView=[[UIScrollView alloc]init];
    //边缘弹动效果
    scrolView.bounces=NO;
    if (HBScreenHeight>700) {
        scrolView.frame=CGRectMake(0, 0, HBScreenWidth, HBScreenHeight-66-49);
    }else{
         scrolView.frame=CGRectMake(0, 0, HBScreenWidth, HBScreenHeight-44-49);
    }
    scrolView.backgroundColor=HBRGBColor(230, 231, 233, 1);
    scrolView.delegate=self;
    [self.view addSubview:scrolView];
    
    //添加视图的滚动
    UIScrollView *scrolViewImage=[[UIScrollView alloc]init];
    scrolViewImage.frame=CGRectMake(0, 0, HBScreenWidth, (HBScreenWidth*1.0)/2.0);
    //scrolViewImage.backgroundColor=[UIColor redColor];
    //按页(scrolView自身的大小)滚动
    scrolViewImage.pagingEnabled=YES;
    scrolViewImage.bounces=NO;
    scrolViewImage.delegate=self;
    [scrolView addSubview:scrolViewImage];
    
    self.titleImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, HBScreenWidth, (HBScreenWidth*1.0)/2.0)];
    self.titleImageView.image=[UIImage imageNamed:@"ad_bar1.jpg"];
    self.titleImageView.userInteractionEnabled=YES;
    [scrolViewImage addSubview:self.titleImageView];
    //手势
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.titleImageView addGestureRecognizer:tap];

    UIView *upNetView=[[UIView alloc]initWithFrame:CGRectMake(0, (HBScreenWidth*1.0)/2.0, HBScreenWidth, 70)];
    upNetView.backgroundColor=[UIColor whiteColor];
    [scrolView addSubview:upNetView];
    
    
    self.userLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 10,(HBScreenWidth-20)/2.0, 25)];
    
    self.userLabel.font=[UIFont systemFontOfSize:12];
    self.userLabel.textAlignment=NSTextAlignmentLeft;
    [upNetView addSubview:self.userLabel];
    
    self.timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(10+(HBScreenWidth-20)/2.0, 10,(HBScreenWidth-20)/2.0, 25)];
    self.timeLabel.textAlignment=NSTextAlignmentRight;
    self.timeLabel.font=[UIFont systemFontOfSize:12];
    [upNetView addSubview:self.timeLabel];
    
    self.wifiLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 35, HBScreenWidth-20-68, 25)];
    
    self.wifiLabel.font=[UIFont systemFontOfSize:12];
    [upNetView addSubview:self.wifiLabel];
    
    self.upButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.upButton.frame=CGRectMake(HBScreenWidth-70, 36, 60, 23);
    [self.upButton setFont:[UIFont systemFontOfSize:13.0]];
    [upNetView addSubview:self.upButton];
    [self.upButton addTarget:self action:@selector(upOrDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    

    UIImageView *myImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, (HBScreenWidth*1.0)/2.0+70, HBScreenWidth, HBScreenWidth*7/75)];
    myImageView.image=[UIImage imageNamed:@"my_account"];
    [scrolView addSubview:myImageView];
    NSMutableArray *upbtnArray1 = [NSMutableArray array];
    NSArray *image=@[@"online_recharge",@"user_register"];
    for (int i=0; i<2; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake((HBScreenWidth*1.0)/2.0*i, (HBScreenWidth*1.0)/2.0+70+HBScreenWidth*7/75, (HBScreenWidth*1.0)/2.0,(HBScreenWidth*1.0)/2.0*165/375 );
        [button setImage:[UIImage imageNamed:image[i]] forState:UIControlStateNormal];
        [scrolView addSubview:button];
        [button addTarget:self action:@selector(upButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [upbtnArray1 addObject:button];
    }
    self.upbtnArray = upbtnArray1;
    
    UIImageView *toolImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, (HBScreenWidth*1.0)/2.0+70+HBScreenWidth*7/75+(HBScreenWidth*1.0)/2.0*165/375 , HBScreenWidth, HBScreenWidth*7/75)];
    toolImageView.image=[UIImage imageNamed:@"wifi_toolbox"];
    [scrolView addSubview:toolImageView];
   NSMutableArray *toolbtnArray1 = [NSMutableArray array];
    NSArray *toolimage=@[@"wifi_list",@"wifi_spectrum",@"download_speedtest",@"webpage_speedtest"];
    for (int i=0; i<4; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake((HBScreenWidth*1.0)/2.0*(i%2), (HBScreenWidth*1.0)/2.0+70+HBScreenWidth*7/75*2+(HBScreenWidth*1.0)/2.0*165/375+(((HBScreenWidth*1.0)/2.0*165/375+10)*(i/2)), (HBScreenWidth*1.0)/2.0,(HBScreenWidth*1.0)/2.0*165/375 );
        [button setImage:[UIImage imageNamed:toolimage[i]] forState:UIControlStateNormal];
        [scrolView addSubview:button];
        [button addTarget:self action:@selector(toolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbtnArray1 addObject:button];
    }
    self.toolbtnArray = toolbtnArray1;
    
     scrolView.contentSize=CGSizeMake(HBScreenWidth,(HBScreenWidth*1.0)/2.0+70+HBScreenWidth*7/75*2+(HBScreenWidth*1.0)/2.0*165/375+(((HBScreenWidth*1.0)/2.0*165/375+10)*1)+49+40);
    
}

//图片点击的手势的方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.modelArr.count>0) {
        
        WIFImodel *model=self.modelArr[0];
        if (model.action_parameter.length>4) {
            
            NSString *urlandtitle=[model.action_parameter substringFromIndex:4];
            NSArray *array = [urlandtitle componentsSeparatedByString:@"&"]; //从字符A中分隔成2个元素的数组
            RuleViewController *ruVC=[[RuleViewController alloc]init];
            ruVC.ruleUrl=array[0];
            NSString *title=[array[1] substringFromIndex:6];
            ruVC.titleStr=title;
            [self.navigationController pushViewController:ruVC animated:YES];
            
            //[SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
        }
      
    }
    

}
//上线下线
-(void)upOrDownButtonAction:(UIButton *)sender
{
    
    
    if ([sender.titleLabel.text isEqual:@"登录"]) {
        
        LoginViewController *logVC=[[LoginViewController alloc]init];
        
        [self.navigationController pushViewController:logVC animated:YES];
        
    }
    
    if ([sender.titleLabel.text isEqual:@"上线"]) {
        
        
        if ([McSystemMessageUtil  netEnvironmentIsWifi]) {
            //是否包含YOUNG的wifi
            NSString *wifiName=[McSystemMessageUtil getWifiName];
            if ([wifiName containsString:@"YOUNG"]) {
            
                    if ([self.wifiLabel.text isEqualToString:@"您还未上线,请点击上线按钮"]) {
                        //[SVProgressHUD showWithStatus:@"正在上线中..."];
                        self.wifiLabel.text=@"正在认证上线...";
                        self.upButton.backgroundColor=[UIColor lightGrayColor];
                        if (self.webView.isLoading) {
                            [self.webView stopLoading];
                        }
                        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
                        
                    }else{
                        
                        [SVProgressHUD showImage:nil status:self.wifiLabel.text];
                        
                    }
                
            }
        }
        
    }
    if ([sender.titleLabel.text isEqual:@"下线"]) {
        if ([McSystemMessageUtil  netEnvironmentIsWifi]) {
            //是否包含YOUNG的wifi
            NSString *wifiName=[McSystemMessageUtil getWifiName];
            if ([wifiName containsString:@"YOUNG"]) {
                self.wifiLabel.text=@"正在下线中...";
                self.upButton.backgroundColor=[UIColor lightGrayColor];
                 NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                 NSString * downStr=[user objectForKey:@"下线"];
        
                if (self.webView_down.isLoading) {
                    [self.webView_down stopLoading];
                }
                 [self.webView_down loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:downStr]]];
        
            }else{
                
                 [SVProgressHUD showImage:nil status:@"请连接带YOUNG的WIFI,再下线"];
            
            }
        }else{
            
            [SVProgressHUD showImage:nil status:@"请连接带YOUNG的WIFI,再下线"];
            
        }
    }

}


//判断有没有网络的方法,
- (BOOL)serachNet
{
    Reachability *reachAbility = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NSInteger stateNet = [reachAbility currentReachabilityStatus];
    
    if (stateNet == 0) {
        
        return NO;
        
    }else{
        
        return YES;
        
    }
}


//退出登录回来的方法
- (void)recieveNotification:(NSNotification *)noti
{
    
    if ([_upButton.titleLabel.text isEqual:@"下线"]) {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        NSString * downStr=[user objectForKey:@"下线"];
        [self.webView_down loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:downStr]]];
        
    }
    
    
}

//上下线的工程
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    NSString *account=userMessage.user_account;
    NSString *password=userMessage.MD5PassWorld;
    
    //获取loaction
    if (webView==self.webView) {
        
        NSString *url=[webView.request.URL.absoluteURL absoluteString];
        NSLog(@"%@",url);
        //能上网的情况下
        if ([url containsString:@"https://m.baidu.com"]||[url containsString:@"https://www.baidu.com/"]) {
            
            NSMutableArray *userArray=[NSMutableArray array];
            userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
            loginOrReginModel *userMessage = userArray.lastObject;
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            parameter[@"trans_code"] = @"query_internet_remaining_time";
            NSDate *nowDate=[NSDate date];
            NSDateFormatter *formater=[[NSDateFormatter alloc]init];
            [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timeStr=[formater stringFromDate:nowDate];
            NSString *time=[timeStr stringByAppendingString:@".300"];
            parameter[@"ptime"] =time;
            parameter[@"from_system"] =FromSystem;
            //@"18:DC:56:21:84:07"
            parameter[@"from_client_id"] =[McSystemMessageUtil getWifiMac];
            parameter[@"from_client_os"] =@"iOS";
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            parameter[@"from_client_version"] =version;
            parameter[@"from_client_desc"] =FromSystem;
            parameter[@"user_account"] = userMessage.user_account;
            
            __weak typeof(self) weakself = self;
            [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
                                    //失败
                    if (dict[@"error_code"]) {
            
                            self.wifiLabel.text=@"您还未上线,请点击上线按钮";
                            self.upButton.backgroundColor=[UIColor orangeColor];
                            return ;
                    } else {  //成功,
            
                            dispatch_async(dispatch_get_main_queue(), ^{
            
                                [self.upButton setTitle:@"下线" forState:UIControlStateNormal];
                                self.upButton.backgroundColor=[UIColor redColor];
                                self.timeLabel.hidden=YES;
            
                                NSString *usertime=dict[@"remaining_time"];
                                NSInteger Stime=[usertime integerValue];
                                self.time=Stime;
                                NSInteger Hour=Stime/3600;
                                NSInteger min=(Stime-Hour*3600)/60;
                                NSString *hourStr;
                                NSString *minStr;
                                if (Hour==0) {
                                    hourStr=@"00";
                                }else{
                                    hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
                                }
                                if (min==0) {
                                    minStr=@"00";
                                }else{
                                    minStr=[NSString stringWithFormat:@"%ld",(long)min];
                                }
                                NSInteger hourlength=hourStr.length;
                                NSInteger minlength=minStr.length;
                                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@时%@分",hourStr,minStr]];
                                [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,hourlength)];
                               [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6+hourlength,minlength)];
                                self.wifiLabel.attributedText = str;
                                self.timeLabel.hidden=YES;
                                    //计时
                                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
                                
                                        });
                                        
                                    }
                                }];
            
            
        }else{
             NSString *fist=[url substringFromIndex:7];
             NSArray *array1 = [fist componentsSeparatedByString:@"/"];
              self.requestIpStr=array1[0];
              NSString *second=array1[1];
              NSArray *array2 = [second componentsSeparatedByString:@"?"];
              NSString *nameIP=array2[1];
              NSArray *array3 = [second componentsSeparatedByString:@"&"];
              self.userIpStr=array3[1];
              //拼接
              self.UpUrlStr=[NSString stringWithFormat:@"http://%@/quickauth.do?%@&userid=%@&passwd=%@",self.requestIpStr,nameIP,account,password];
            if (self.webView_test.isLoading) {
                [self.webView_test stopLoading];
            }
              [self.webView_test loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.UpUrlStr]]];
        }
    }
    
    //上线
    if (webView==self.webView_test) {
        
        NSString *lJs = @"document.documentElement.innerHTML";
        NSString *lHtml1 = [self.webView_test stringByEvaluatingJavaScriptFromString:lJs];
        
        NSString *jsfist=[lHtml1 substringFromIndex:19];
        NSArray *jsarray = [jsfist componentsSeparatedByString:@"<"];
        NSString *jsStr=jsarray[0];
        NSData *jsonData = [jsStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        self.jsDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&err];
        
        if ([self.jsDic[@"code"] isEqualToString:@"0"]) {
            
            [SVProgressHUD showSuccessWithStatus:self.jsDic[@"rec"]];
            [self.upButton setTitle:@"下线" forState:UIControlStateNormal];
            self.upButton.backgroundColor=[UIColor redColor];
            self.timeLabel.hidden=YES;
            
            NSString *usertime=self.jsDic[@"usertime"];
            NSInteger Stime=[usertime integerValue];
            self.time=Stime;
            NSInteger Hour=Stime/3600;
            NSInteger min=(Stime-Hour*3600)/60;
            NSString *hourStr;
            NSString *minStr;
            if (Hour==0) {
                hourStr=@"00";
            }else{
                hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
            }
            if (min==0) {
                minStr=@"00";
            }else{
                minStr=[NSString stringWithFormat:@"%ld",(long)min];
            }
            NSInteger hourlength=hourStr.length;
            NSInteger minlength=minStr.length;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@时%@分",hourStr,minStr]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,hourlength)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6+hourlength,minlength)];
            self.wifiLabel.attributedText = str;
            self.timeLabel.hidden=YES;
            //计时
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
            //拼接
            self.DownUrlStr=[NSString stringWithFormat:@"http://%@/quickauthdisconn.do?wlanacIp=%@&%@&userid=%@&version=%@",self.requestIpStr,self.jsDic[@"wlanacIp"],self.userIpStr,account,self.jsDic[@"version"]];
               NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                [user setObject:self.DownUrlStr forKey:@"下线"];
            
        }else{
            
            self.wifiLabel.text=@"您还未上线,请点击上线按钮";
            [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
            self.upButton.backgroundColor=[UIColor orangeColor];
            [SVProgressHUD showImage:nil status:self.jsDic[@"rec"]];
        }
        
    }
    
    //下线
    if (webView==self.webView_down) {
        
        NSString *lJs = @"document.documentElement.innerHTML";
        NSString *lHtml1 = [self.webView_down stringByEvaluatingJavaScriptFromString:lJs];
        
        NSString *jsfist=[lHtml1 substringFromIndex:19];
        NSArray *jsarray = [jsfist componentsSeparatedByString:@"<"];
        NSString *jsStr=jsarray[0];
        NSData *jsonData = [jsStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        self.jsDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&err];
        
        if ([self.jsDic[@"code"] isEqualToString:@"0"]) {
            
            [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
            self.upButton.backgroundColor=[UIColor orangeColor];
            self.wifiLabel.text=@"您还未上线,请点击上线按钮";
            [self.timer setFireDate:[NSDate distantFuture]];
            NSInteger Hour=self.time/3600;
            NSInteger min=(self.time-Hour*3600)/60;
            NSString *hourStr;
            NSString *minStr;
            
            if (Hour==0) {
                hourStr=@"00";
            }else{
                hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
            }
            if (min==0) {
                minStr=@"00";
            }else{
                minStr=[NSString stringWithFormat:@"%ld",(long)min];
            }
            NSInteger hourlength=hourStr.length;
            NSInteger minlength=minStr.length;
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@:%@",hourStr,minStr]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(5,hourlength+minlength+1)];
            self.timeLabel.attributedText = str;
            self.timeLabel.hidden=NO;
            NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
            [user setObject:@"" forKey:@"下线"];
            //[SVProgressHUD showSuccessWithStatus:self.jsDic[@"rec"]];
            
        }else{
            
            NSInteger Hour=self.time/3600;
            NSInteger min=(self.time-Hour*3600)/60;
            NSString *hourStr;
            NSString *minStr;
            if (Hour==0) {
                hourStr=@"00";
            }else{
                hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
            }
            if (min==0) {
                minStr=@"00";
            }else{
                minStr=[NSString stringWithFormat:@"%ld",(long)min];
            }
            NSInteger hourlength=hourStr.length;
            NSInteger minlength=minStr.length;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@时%@分",hourStr,minStr]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,hourlength)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6+hourlength,minlength)];
            self.timeLabel.hidden=YES;
            self.wifiLabel.attributedText = str;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
            self.upButton.backgroundColor=[UIColor redColor];
           // [SVProgressHUD showErrorWithStatus:self.jsDic[@"rec"]];
            
        }
        
        [SVProgressHUD showImage:nil status:self.jsDic[@"rec"]];
        
    }
    
}

//有错误的时候
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error) {
        
        if (webView==self.webView || webView==self.webView_test) {
            
            self.wifiLabel.text=@"您还未上线,请点击上线按钮";
            [self.upButton setTitle:@"上线" forState:UIControlStateNormal];
            self.upButton.backgroundColor=[UIColor orangeColor];
            [SVProgressHUD showImage:nil status:@"上线失败!"];
        }
        if (webView==self.webView_down){
            
            NSInteger Hour=self.time/3600;
            NSInteger min=(self.time-Hour*3600)/60;
            NSString *hourStr;
            NSString *minStr;
            if (Hour==0) {
                hourStr=@"00";
            }else{
                hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
            }
            if (min==0) {
                minStr=@"00";
            }else{
                minStr=[NSString stringWithFormat:@"%ld",(long)min];
            }
            NSInteger hourlength=hourStr.length;
            NSInteger minlength=minStr.length;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@时%@分",hourStr,minStr]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,hourlength)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6+hourlength,minlength)];
            self.wifiLabel.attributedText = str;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
            self.upButton.backgroundColor=[UIColor redColor];
            
            [SVProgressHUD showImage:nil status:@"下线失败!"];
            
            
        }
        
    }

}



//button的点击方法
- (void)upButtonAction:(UIButton *)sender
{
    //支付
    if ([self.upbtnArray indexOfObject:sender] == 0) {
    
        payViewController *payVC=[[payViewController alloc]init];
        [self.navigationController pushViewController:payVC animated:YES];
    
    } else if ([self.upbtnArray indexOfObject:sender] == 1) {
    
        //用户注册
        RegisterANDForginViewController *regVC=[[RegisterANDForginViewController alloc]init];
        regVC.fogin=NO;
        [self.navigationController pushViewController:regVC animated:YES];
    
    }
    
}

- (void)toolButtonAction:(UIButton *)sender
{
    //AP列表
    if ([self.toolbtnArray indexOfObject:sender] == 0) {
        
        [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
   
        
    } else if ([self.toolbtnArray indexOfObject:sender] == 1) {
        //频谱图
        [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
        
    } else if ([self.toolbtnArray indexOfObject:sender] == 2) {
        
        //下载测速
        [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
        
        
    } else if ([self.toolbtnArray indexOfObject:sender] == 3) {
        
        //网页测试
        TestNetViewController *testVC=[[TestNetViewController alloc]init];
        [self.navigationController pushViewController:testVC animated:YES];
        
        //[SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
        
    }
    
    
}

- (void)dealloc
{
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"outlogin" object:nil];
    
}

#pragma mark - 定时器的方法
- (void)timeAction{
    
    if (self.time<60) {
        [self.timer setFireDate:[NSDate distantFuture]];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:00时00分"]];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,2)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8,2)];
        self.wifiLabel.attributedText = str;
        
        return;
    }
    
    self.time--;;
    NSInteger Hour=self.time/3600;
    NSInteger min=(self.time-Hour*3600)/60;
    NSString *hourStr;
    NSString *minStr;
    if (Hour==0) {
        hourStr=@"00";
    }else{
        hourStr=[NSString stringWithFormat:@"%ld",(long)Hour];
    }
    if (min==0) {
        minStr=@"00";
    }else{
        minStr=[NSString stringWithFormat:@"%ld",(long)min];
    }
    NSInteger hourlength=hourStr.length;
    NSInteger minlength=minStr.length;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"剩余时间:%@时%@分",hourStr,minStr]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,hourlength)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6+hourlength,minlength)];
    self.wifiLabel.attributedText = str;
    
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
