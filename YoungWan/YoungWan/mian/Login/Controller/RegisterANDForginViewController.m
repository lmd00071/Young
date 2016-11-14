//
//  RegisterANDForginViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/12.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "RegisterANDForginViewController.h"
#import<CommonCrypto/CommonDigest.h>
@interface RegisterANDForginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *telePhoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWroldTextField;

@property (strong, nonatomic) IBOutlet UITextField *agingPassWrold;

@property (strong, nonatomic) IBOutlet UIButton *sendCodeButton;

@property (strong, nonatomic) IBOutlet UIButton *trueButton;

@property (nonatomic, strong) BWHttpRequestManager *manager;
//设置定时器
@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,assign)NSInteger time;


@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;
@end

@implementation RegisterANDForginViewController


- (BWHttpRequestManager *)manager
{
    if (_manager == nil) {
        BWHttpRequestManager *manager = [[BWHttpRequestManager alloc] init];
        _manager = manager;
    }
    return _manager;
}


//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if (self.fogin) {
        
        self.navigationItem.title=@"找回密码";
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        self.telePhoneTextField.text=[user objectForKey:@"请输入手机号码"];
        self.nameTextField.text=[user objectForKey:@"请输入域名"];
        
    }else{
        self.navigationItem.title=@"注册";
        self.passWroldTextField.placeholder=@"请输入密码";
        self.agingPassWrold.placeholder=@"请再次输入密码";
        [self.trueButton setTitle:@"注册并登录" forState:UIControlStateNormal];
    }
    UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [popBtn setImage:[UIImage imageNamed:@"back32"] forState:UIControlStateNormal];
    [popBtn sizeToFit];
    [popBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBtn];
    // Do any additional setup after loading the view from its nib.
    
     [self setupCancelSuccess];
    
}
- (IBAction)sendCodeAction:(UIButton *)sender {
    
    
    if ([self.telePhoneTextField.text isEqualToString:@""]) {
        
        [SVProgressHUD showImage:nil status:@"手机号码不能为空!"];
        return;
    }
    
    if (self.telePhoneTextField.text.length!=11) {
        
        [SVProgressHUD showImage:nil status:@"手机号码个数不正确"];
        
        return;
    }
    NSString *account = self.telePhoneTextField.text;
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
    //parameter[@"from_client_id"] =@"18:DC:56:21:84:07";
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
                
                //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
                
            });
           
        } else {  //成功,
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showImage:nil status:@"发送成功"];
            //开启定时
            self.time=90;
            self.sendCodeButton.titleLabel.text =[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] ;
            [self.sendCodeButton setTitle:[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] forState:UIControlStateNormal];
            self.sendCodeButton.backgroundColor=[UIColor lightGrayColor];
            self.sendCodeButton.userInteractionEnabled=NO;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
            

             });
        }
    }];

    

}
- (IBAction)trueAction:(UIButton *)sender {
    
    if (self.fogin) {
        
        if (![self.passWroldTextField.text isEqualToString:self.agingPassWrold.text]) {
            
            self.backgroundView.hidden=NO;
            self.errorStringLabel.text=@"两次输入密码不一致";
            
            return;
            
        }
        
        //忘记密码
        [SVProgressHUD showWithStatus:@"验证中..."];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
        parameter[@"trans_code"] = @"match_verification_code";
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
        parameter[@"msisdn"] = self.telePhoneTextField.text;
        parameter[@"verification_code"] = self.codeTextField.text;
        
        
        [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
            //失败
            [SVProgressHUD dismiss];
            if (dict[@"error_code"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                    self.backgroundView.hidden=NO;
                    self.errorStringLabel.text=dict[@"error_string"];
                    
                });
                
            } else {  //成功,
                
                //修改密码
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self changepassword];
                    
                });
                
                
            }
        }];

        
        
    }else{
    
        if ([self.passWroldTextField.text isEqualToString:self.agingPassWrold.text]) {
            //注册
            NSString *account = self.telePhoneTextField.text;
            [SVProgressHUD showWithStatus:@"正在注册中..."];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
            parameter[@"trans_code"] = @"user_register";
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
            NSString *md5=[self md5:self.passWroldTextField.text];
            NSRange range={8,16};
            NSString *findish=[md5 substringWithRange:range];
            NSString *xiaoxie=[findish lowercaseString];
            parameter[@"user_password"] =xiaoxie;
            parameter[@"net_account"] = @"";
            parameter[@"net_password"] = @"";
            parameter[@"domain"] = self.nameTextField.text;
            parameter[@"imei"] = @"";
            parameter[@"imsi"] = @"";
            parameter[@"is_new_terminal"] = @"";
            
            
            [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
                //失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                
                if (dict[@"error_code"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                        self.backgroundView.hidden=NO;
                        self.errorStringLabel.text=dict[@"error_string"];
                    });
                    
                } else {  //成功,
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //[SVProgressHUD showImage:nil status:@"注册成功"];
                        //[self verify];
                        self.backgroundView.hidden=NO;
                        self.errorStringLabel.text=@"注册成功";
                    });
                }
            }];
        }else{
        
            dispatch_async(dispatch_get_main_queue(), ^{
               [SVProgressHUD showImage:nil status:@"两次输入的密码不一致"];
               
            });
           
        }
    }
    
}

//修改密码
- (void)changepassword
{
    [SVProgressHUD showWithStatus:@"正在修改中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"change_password";
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
    parameter[@"user_account"] =@"";
    parameter[@"msisdn"] = self.telePhoneTextField.text;
    parameter[@"domain"] = self.nameTextField.text;
    NSString *md5=[self md5:self.passWroldTextField.text];
    NSRange range={8,16};
    NSString *findish=[md5 substringWithRange:range];
    NSString *xiaoxie=[findish lowercaseString];
    parameter[@"new_password"] =xiaoxie;
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        [SVProgressHUD dismiss];
        if (dict[@"error_code"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
                
            });
            
        } else {  //成功,
            
            //修改密码
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=@"修改成功";
                
            });
            
            
        }
    }];


}

// md5
-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

//验证
- (void)verify
{

    NSString *account = self.telePhoneTextField.text;
    [SVProgressHUD showWithStatus:@"正在验证中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"user_info_check";
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
    parameter[@"verification_code"] = self.codeTextField.text;
    parameter[@"domain"] = self.nameTextField.text;
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        if (dict[@"error_code"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
            });
            
        } else {  //成功,
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[SVProgressHUD showImage:nil status:@"注册成功"];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=@"注册成功";
            
            });
        }
    }];

}



//注册成功后登陆
- (void)login
{
    NSString *account = self.telePhoneTextField.text;
    [SVProgressHUD showWithStatus:@"正在登录中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"user_login";
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
    NSString *md5=[self md5:self.passWroldTextField.text];
    NSRange range={8,16};
    NSString *findish=[md5 substringWithRange:range];
    NSString *xiaoxie=[findish lowercaseString];
    parameter[@"user_password"] =xiaoxie;
    parameter[@"domain"] = self.nameTextField.text;
    parameter[@"imei"] = @"869336029608773";
    parameter[@"imsi"] = @"fawuhuoquIMSI";
    parameter[@"is_new_terminal"] = @"N";
    
    __weak typeof(self) weakself = self;
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        if (dict[@"error_code"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
            //[SVProgressHUD showErrorWithStatus:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
                
            });
        } else {  //成功,
            
            loginOrReginModel *model = [[loginOrReginModel alloc]init];
            model.user_account=dict[@"user_account"];
            model.bind_account=dict[@"bind_account"];
            NSRange range={0,11};
            NSString *findish=[dict[@"user_account"] substringWithRange:range];
            model.user_account_uid=findish;
            model.MD5PassWorld=xiaoxie;
            //将用户数据存到数据库中
            NSMutableArray *userArray=[NSMutableArray array];
            userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
            loginOrReginModel *userMessage = userArray.lastObject;
            if (userArray.count > 0) {
                
                NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '%@',  bind_account='%@', user_account='%@', MD5PassWorld='%@', photo_raw_url='%@'", model.user_account_uid, model.bind_account, model.user_account, model.MD5PassWorld, model.photo_raw_url];
                [LoginUserManager modifyData:modifyString];
                
            } else {
                //文件的路径是文件夹的路径+文件
                
                [LoginUserManager insertModal:model];
                
            }
            //登录成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                //是否从首页来注册
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    [user setObject:self.telePhoneTextField.text forKey:@"请输入手机号码"];
                    [user setObject:self.nameTextField.text forKey:@"请输入域名"];
                    for (UINavigationController *navVc in weakself.tabBarController.childViewControllers) {
                        
                        if (navVc.childViewControllers.count > 1) {
                            if (self.fage) {
                                [navVc popViewControllerAnimated:YES];
                            }else{
                               
                                [navVc popToRootViewControllerAnimated:YES];
                            }
                        }
                    }
              
            
            });
            
        }
    }];
    

}


- (void)backAction:(UIButton *)sneder
{
    
    [self.navigationController popViewControllerAnimated:YES];

}
//点击屏幕的时候收起键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.telePhoneTextField isExclusiveTouch]) {
        [self.telePhoneTextField resignFirstResponder];
    }
    if (![self.nameTextField isExclusiveTouch]) {
        [self.nameTextField resignFirstResponder];
    }
    if (![self.codeTextField isExclusiveTouch]) {
        [self.codeTextField resignFirstResponder];
    }
    if (![self.passWroldTextField isExclusiveTouch]) {
        [self.passWroldTextField resignFirstResponder];
    }
    if (![self.agingPassWrold isExclusiveTouch]) {
        [self.agingPassWrold resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    
    if ([textField.placeholder isEqualToString:@"请填写收货姓名"]) {
        [user setObject:textField.text forKey:@"请填写收货姓名"];
        
    }else if ([textField.placeholder isEqualToString:@"请输入手机号码"]) {
        [user setObject:textField.text forKey:@"请输入手机号码"];
        
    }else if ([textField.placeholder isEqualToString:@"请填写配送地址"]) {
        [user setObject:textField.text forKey:@"请填写配送地址"];
        
    }
  
    
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
    if ([self.errorStringLabel.text isEqualToString:@"注册成功"]||[self.errorStringLabel.text isEqualToString:@"修改成功"]) {
        [self login];
    }
}


#pragma mark - 定时器的方法
- (void)timeAction{
    
    if (self.time==0) {
        [self.timer setFireDate:[NSDate distantFuture]];
        self.sendCodeButton.backgroundColor=HBRGBColor(25, 199, 114, 1);
        self.sendCodeButton.titleLabel.text =@"发送验证码";
        self.sendCodeButton.userInteractionEnabled=YES;
        [self.sendCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        
        return;
    }
    self.time--;
    self.sendCodeButton.titleLabel.text =[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] ;
    [self.sendCodeButton setTitle:[NSString stringWithFormat:@"发送验证码(%ld)",(long)self.time] forState:UIControlStateNormal];

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
