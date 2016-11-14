//
//  BWPasswordController.m
//  WidomStudy
//
//  Created by Sigbit on 16/1/12.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWPasswordController.h"
#define NavBarFgColor [UIColor whiteColor]
#define NavTextAttribute @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}
@interface BWPasswordController ()

@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *outBtn;

@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *userTask;

@end

@implementation BWPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    self.navigationItem.title = @"修改名字";
    //设置成导航栏下面开始计算
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back32"] style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    self.changeBtn.backgroundColor = HBConstColor;
    self.outBtn.backgroundColor = HBConstColor;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark - 返回按键的方法
- (void)leftAction{
    
    [self.dnsTask cancel];
    [self.csvTask cancel];
    [self.userTask cancel];
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)reviseClick:(id)sender {
    
    [SVProgressHUD showWithStatus:@"正在提交新名字..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"user_info_set";
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
    parameter[@"yc_mobile_operator"] =@"move";
    parameter[@"yc_using_wifi"] =@"Y";
    parameter[@"user_name"] = self.passwordField.text;
    parameter[@"user_email"] = @"";
    parameter[@"user_msisdn"] = @"";
    parameter[@"upload_receipt_photo"] = @"";
    parameter[@"upload_photo_file"] = @"";
    
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

    //获取请求地址
    NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:dnsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"修改名字失败"];
            });
            return;
        }
        
        NSDictionary *dnsDict = [NSDictionary dictionaryWithXMLData:data];
        NSMutableURLRequest *csvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsDict[@"dns.url"]]];
        [csvRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSStringToBetyArray *tool=[[NSStringToBetyArray alloc]init];
        csvRequest.HTTPBody = [tool encryptString:xmlString];
        csvRequest.HTTPMethod = @"POST";
        
        //获取学校地址
        NSURLSessionDataTask *urlTask = [session dataTaskWithRequest:csvRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showImage:nil status:@"修改名字失败"];
                });
                return;
            }
            
            NSDictionary *urlDict = [NSDictionary dictionaryWithXMLData:data];
            if (urlDict[@"error_code"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD showImage:nil status:urlDict[@"error_string"]];
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showImage:nil status:@"修改成功"];
                self.changeNameblock(self.passwordField.text);
                [self.navigationController popViewControllerAnimated:YES];
                
            });
            
            
//                dispatch_async(dispatch_get_main_queue(), ^{
//                   
//                        [SVProgressHUD showWithStatus:@"正在刷新用户信息"];
//                        
//                        NSMutableDictionary *para = [NSMutableDictionary dictionary];
//                        para[@"trans_code"] = @"user_info_get";
//                        para[@"from_system"] = FromSystem;
//                        //拿到当前版本号
//                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//                        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//                        para[@"from_client_version"] = version;
//                        //拿到手机的MAC地址
//                        para[@"from_client_id"] = AppUUID;
//                        para[@"yc_user_role"] = UserRole;
//                        para[@"yc_user_account_uid"] = userMessage.user_account_uid;
//                       
//                        
//                        //修改成功,请求用户信息
//                        NSString *requestString = [para newXMLString];
//                        
//                        NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsDict[@"dns.url"]]];
//                        
//                        [userRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//                        userRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
//                        userRequest.HTTPMethod = @"POST";
//                        
//                        NSURLSessionDataTask *userTask = [session dataTaskWithRequest:userRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                            
//                            if (error) {
//                                [SVProgressHUD showErrorWithStatus:@"刷新用户信息失败..."];
//                                return;
//                            }
//                            
//                            NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLData:data];
//                            
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                
//                                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
//                                
//                                //将用户数据存到数据库中
//                                loginOrReginModel *model = [loginOrReginModel mj_objectWithKeyValues:xmlDict];
//                                NSMutableArray *userArray=[NSMutableArray array];
//                                userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
//                                if (userArray.count > 0) {
//                                    NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '%@',  user_name='%@', user_msisdn='%@', photo_icon_url='%@', photo_raw_url='%@'", model.user_account_uid, model.user_name, model.user_msisdn, model.photo_icon_url, model.photo_raw_url];
//                                    [LoginUserManager modifyData:modifyString];
//                                    
//                                } else {
//                                    [LoginUserManager insertModal:model];
//                                }
//                                
//                                [weakself.navigationController popViewControllerAnimated:YES];
//                            });
//                        }];
//                        [userTask resume];
//                    self.userTask=userTask;
//                });
  
        }];
        [urlTask resume];
        weakself.csvTask = urlTask;
    }];
    [dnsTask resume];
    self.dnsTask = dnsTask;
}

- (IBAction)quitClick:(id)sender {
    
    [self.dnsTask cancel];
    [self.csvTask cancel];
    [self.userTask cancel];
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
