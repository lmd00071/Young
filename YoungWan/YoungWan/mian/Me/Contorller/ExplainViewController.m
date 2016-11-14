//
//  ExplainViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/9/27.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "ExplainViewController.h"

@interface ExplainViewController ()

@property (strong, nonatomic) IBOutlet UILabel *subTitleLable;

@property (nonatomic, strong) BWHttpRequestManager *manager;
@end

@implementation ExplainViewController


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
    self.navigationItem.title=self.titles;
    
    if ([self.titles isEqualToString:@"注意事项"]) {
        
        self.subTitleLable.text=self.subTitle;
    }
    
    
    if ([self.titles isEqualToString:@"通知"]) {
        [self httpFromNet];
    }
    
}

- (void)httpFromNet
{
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSString *account=[user objectForKey:@"请输入手机号码"];
    [SVProgressHUD showWithStatus:@"正在加载中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"announcement_fetch";
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
    parameter[@"yc_msisdn"] = account;
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
                
                if (dict[@"title"]){
                    
                    if ([dict[@"title"] isEqualToString:@""]) {
                        
                        self.subTitleLable.text=@"暂无通知";
                        
                    }else{
                        
                        self.subTitleLable.text=dict[@"title"];
                    }
                }else{
                    
                    self.subTitleLable.text=@"暂无通知";
                
                }
                

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
