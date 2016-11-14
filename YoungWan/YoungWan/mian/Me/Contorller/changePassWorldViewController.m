//
//  changePassWorldViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/10/8.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "changePassWorldViewController.h"
#import<CommonCrypto/CommonDigest.h>
@interface changePassWorldViewController ()
@property (strong, nonatomic) IBOutlet UITextField *passWorldTextField;
@property (strong, nonatomic) IBOutlet UITextField *NewPassWorldTextField;
@property (strong, nonatomic) IBOutlet UITextField *againPassWorldTextField;

@property (nonatomic, strong) BWHttpRequestManager *manager;
@end

@implementation changePassWorldViewController

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
    self.navigationItem.title=@"更改密码";
    self.navigationController.navigationBar.translucent = NO;
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //密文输入
    _NewPassWorldTextField.secureTextEntry=YES;
    _againPassWorldTextField.secureTextEntry=YES;
}

- (IBAction)tuerAction:(UIButton *)sender {
    
    if ([_passWorldTextField.text isEqualToString:@""]||[_NewPassWorldTextField.text isEqualToString:@""]||[_againPassWorldTextField.text isEqualToString:@""]) {
    
        [SVProgressHUD showImage:nil status:@"不能有空缺,请全部填写!"];
        return;
    }
    
    if (![_NewPassWorldTextField.text isEqualToString:_againPassWorldTextField.text]) {
        
        [SVProgressHUD showImage:nil status:@"两次填写密码不一致!"];
        return;
    }
    
    [self changePassWorld];
    
    
}

// md5
-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

//修改密码
- (void)changePassWorld
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
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    if(userMessage.user_account.length>0){
        
        parameter[@"user_account"] = userMessage.user_account;
        
    }
    parameter[@"msisdn"] = @"";
    parameter[@"domain"] = @"";
    NSString *md5=[self md5:self.NewPassWorldTextField.text];
    NSRange range={8,16};
    NSString *findish=[md5 substringWithRange:range];
    NSString *xiaoxie=[findish lowercaseString];
    parameter[@"new_password"] =xiaoxie;
    
    [self.manager httpRequestManagerSetupRequestWithParametersDictionary:parameter action:@"" actionParameter:@"" hasParameter:NO dataBlock:^(NSDictionary *dict) {
        //失败
        [SVProgressHUD dismiss];
        if (dict[@"error_code"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showImage:nil status:dict[@"error_string"]];
               
            });
            
        } else {  //成功,
            
            //修改密码
            dispatch_async(dispatch_get_main_queue(), ^{
    
                [SVProgressHUD showImage:nil status:@"修改成功"];
                self.changePassWorldblock(YES);
                [self.navigationController popViewControllerAnimated:YES];
                
            });
            
            
        }
    }];

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
