//
//  UNBindViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/9/30.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "UNBindViewController.h"

@interface UNBindViewController ()<UITextFieldDelegate>
//发送验证码
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
//说明文字
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
//发送验证码的按键
@property (strong, nonatomic) IBOutlet UIButton *sendCodeButton;

@property (nonatomic, strong) BWHttpRequestManager *manager;
//设置定时器
@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,assign)NSInteger time;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;
@end

@implementation UNBindViewController

- (BWHttpRequestManager *)manager
{
    if (_manager == nil) {
        BWHttpRequestManager *manager = [[BWHttpRequestManager alloc] init];
        _manager = manager;
    }
    return _manager;
}


//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
 
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title=@"绑定宽带账号";
    UITapGestureRecognizer *huitap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(huishou:)];
    [self.view addGestureRecognizer:huitap];
    [self setupCancelSuccess];
    //说明
    _titleLabel.text=@"温馨提示:\n1.宽带账号无需输入@域名.\n2.宽带账号停用的,关联WIFI账号的赠送时长自动回收,充值复通后自动恢复赠送.";
    
}

- (IBAction)snegCodeAction:(UIButton *)sender {
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSString *account=[user objectForKey:@"请输入手机号码"];
    [SVProgressHUD showWithStatus:@"正在发送中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"send_verification_code";
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
    parameter[@"msisdn"] = account;
    parameter[@"purpose"] = @"";
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        if (dict[@"error_code"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showImage:nil status:dict[@"error_string"]];
            });
            
        } else {  //成功,
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showImage:nil status:@"发送成功"];
                //开启定时
                self.time=90;
                self.sendCodeButton.userInteractionEnabled=NO;
                self.sendCodeButton.titleLabel.text = [NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time];
                [self.sendCodeButton setTitle:[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] forState:UIControlStateNormal];
                self.sendCodeButton.backgroundColor=[UIColor lightGrayColor];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
                
                
            });
        }
    }];

    
    
}

- (IBAction)unBingAction:(UIButton *)sender {
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSString *account=[user objectForKey:@"请输入手机号码"];
    [SVProgressHUD showWithStatus:@"正在解绑中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"user_unbind";
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
    parameter[@"msisdn"] = account;
    parameter[@"verify_code"] = self.codeTextField.text;
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        if (dict[@"error_code"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
               // [SVProgressHUD showImage:nil status:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
            });
            
        } else {  //成功,
            dispatch_async(dispatch_get_main_queue(), ^{
                //[SVProgressHUD showImage:nil status:@"解绑成功"];
                //开启定时
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=@"解绑成功";
                
                NSMutableArray *userArray=[NSMutableArray array];
                userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
                loginOrReginModel *userMessage = userArray.lastObject;
                NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '%@',  bind_account='', user_account='%@', MD5PassWorld='%@', photo_raw_url='%@'", userMessage.user_account_uid, userMessage.user_account, userMessage.MD5PassWorld, userMessage.photo_raw_url];
                [LoginUserManager modifyData:modifyString];
                

                
            });
        }
    }];

    
}


//点击回收的方法
- (void)huishou:(UITapGestureRecognizer *)tap
{
    
    [self.view endEditing:YES];
}

#pragma mark - textfield协议方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - 定时器的方法
- (void)timeAction{
    
    if (self.time==0) {
        [self.timer setFireDate:[NSDate distantFuture]];
        self.sendCodeButton.backgroundColor=HBRGBColor(25, 199, 114, 1);
        self.sendCodeButton.userInteractionEnabled=YES;
        self.sendCodeButton.titleLabel.text = @"发送验证码";
        [self.sendCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        
        return;
    }
    self.time--;
    self.sendCodeButton.titleLabel.text = [NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time];
    [self.sendCodeButton setTitle:[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([self.errorStringLabel.text isEqualToString:@"解绑成功"]) {
        self.unbindblock(@"解绑成功");
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
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
