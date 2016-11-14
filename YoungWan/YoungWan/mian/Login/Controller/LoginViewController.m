//
//  LoginViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/12.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterANDForginViewController.h"
#import<CommonCrypto/CommonDigest.h>
@interface LoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *telePhoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWroldTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) BWHttpRequestManager *manager;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;
@end

@implementation LoginViewController

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
    
    self.navigationController.navigationBarHidden = NO;
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    self.telePhoneTextField.text=[user objectForKey:@"请输入手机号码"];
    self.nameTextField.text=[user objectForKey:@"请输入域名"];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    self.loginButton.layer.cornerRadius=15;
    self.loginButton.clipsToBounds=YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title=@"登录";
    UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [popBtn setImage:[UIImage imageNamed:@"back32"] forState:UIControlStateNormal];
    [popBtn sizeToFit];
    [popBtn addTarget:self action:@selector(popClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBtn];
    
    UIButton *reginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reginBtn setTitle:@"注册" forState:UIControlStateNormal];
    reginBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    reginBtn.tintColor=[UIColor whiteColor];
    [reginBtn sizeToFit];
    [reginBtn addTarget:self action:@selector(reginClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reginBtn];
    
    self.passWroldTextField.secureTextEntry=YES;
    [self setupCancelSuccess];
    
}

// md5
-(NSString *)md5:(NSString *)str {

    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}



- (IBAction)loginAction:(UIButton *)sender {
    
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
    //parameter[@"user_password"]=@"ac59075b964b0715";
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
            
        dispatch_async(dispatch_get_main_queue(), ^{
            
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
            //loginOrReginModel *userMessage = userArray.lastObject;
            
            NSLog(@"%@",model.bind_account);
            
            if (userArray.count > 0) {
                
                NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '%@',  bind_account='%@', user_account='%@', MD5PassWorld='%@', photo_raw_url='%@'", model.user_account_uid, model.bind_account, model.user_account, model.MD5PassWorld, model.photo_raw_url];
                [LoginUserManager modifyData:modifyString];
                
                
            } else {
                //文件的路径是文件夹的路径+文件
                
                [LoginUserManager insertModal:model];
               
            }
            //登录成功
       
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
              for (UINavigationController *navVc in weakself.tabBarController.childViewControllers) {
                  
                  if (navVc.childViewControllers.count > 1) {
                      
                      [navVc popViewControllerAnimated:YES];
                  }
              }
          });
           
        }
    }];

}

- (IBAction)foginPassWroldAction:(UIButton *)sender {
    
    RegisterANDForginViewController *regVC=[[RegisterANDForginViewController alloc]init];
    regVC.fogin=YES;
    [self.navigationController pushViewController:regVC animated:YES];
    
}
//返回的事件
- (void)popClick
{
    [SVProgressHUD dismiss];
    
    if (self.tabBarController.selectedIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.tabBarController.selectedIndex = 0;
    }
}
//注册的事件
- (void)reginClick
{
    RegisterANDForginViewController *regVC=[[RegisterANDForginViewController alloc]init];
    regVC.fogin=NO;
    regVC.fage=NO;
    [self.navigationController pushViewController:regVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

//点击屏幕的时候收起键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.telePhoneTextField isExclusiveTouch]) {
        [self.telePhoneTextField resignFirstResponder];
    }
    if (![self.passWroldTextField isExclusiveTouch]) {
        [self.passWroldTextField resignFirstResponder];
    }
    if (![self.nameTextField isExclusiveTouch]) {
        [self.nameTextField resignFirstResponder];
    }
    
    

}
#pragma mark - textfield协议方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField

{
    
    
}
//输入框编辑完成以后，将视图恢复到原始状态

-(void)textFieldDidEndEditing:(UITextField *)textField
{   NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    
    if ([textField.placeholder isEqualToString:@"请输入手机号码"]) {
        [user setObject:textField.text forKey:@"请输入手机号码"];
        
    }else if ([textField.placeholder isEqualToString:@"请输入域名"]) {
        [user setObject:textField.text forKey:@"请输入域名"];
        
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
    

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     //Get the new view controller using [segue destinationViewController].
     //Pass the selected object to the new view controller.
    
}


@end
