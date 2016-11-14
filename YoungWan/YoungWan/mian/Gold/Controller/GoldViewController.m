//
//  GoldViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/8/16.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "GoldViewController.h"
#import "GoldTableViewController.h"
#import "BWShakeController.h"
#import "WIFImodel.h"
#import "RuleViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "FirenfRankViewController.h"
@interface GoldViewController ()

/*金币的数量 */
@property (strong, nonatomic) IBOutlet UILabel *gold_num;
//标题的
@property (strong, nonatomic) IBOutlet UIImageView *titleImageView;
//第二个标题的imageView
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic,strong)NSMutableArray *modelArr;
@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;
@end

@implementation GoldViewController

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



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SVProgressHUD dismiss];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=HBRGBColor(230, 231, 233, 1);
    self.navigationItem.title=@"赚金币";
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
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
    
    //    parameter[@"yc_mobile_operator"] = @"中国电信";
    //    parameter[@"yc_using_wifi"] = @"Y";
    parameter[@"action"] = @"show_home_page";
    parameter[@"action_parameter"] = @"layout_id=gold";
    
    NSString *xmlString = [parameter newXMLString];
    xmlString = [parameter newXMLString];
    
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
            
            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
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
                        
                        WIFImodel *model = [WIFImodel mj_objectWithKeyValues:picDict];
                        [self.modelArr addObject:model];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        WIFImodel *model=self.modelArr[0];
                        [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"ad_bar1.jpg"]];
                        WIFImodel *model7=self.modelArr[7];
                        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:model7.image] placeholderImage:nil];
                        
                        WIFImodel *model8=self.modelArr[8];
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:model8.image] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            
                            [self.leftButton setBackgroundImage:image forState:UIControlStateNormal];
                        }];
                        WIFImodel *model9=self.modelArr[9];
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:model9.image] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            
                            [self.rightButton setBackgroundImage:image forState:UIControlStateNormal];
                        }];
                        
                        [SVProgressHUD dismiss];
                        
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
//花金币
- (IBAction)leftAction:(UIButton *)sender {
    
    [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
}

//花金币
- (IBAction)rightAction:(UIButton *)sender {
    
    [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
}

//我的金币
- (IBAction)my_glod:(UIButton *)sender {
    
//    //创建Storyboard
    UIStoryboard *meST=[UIStoryboard storyboardWithName:@"Gold" bundle:[NSBundle mainBundle]];
    //我的
    //第一个参数是上面创建的,第二个是storyboard ID
    GoldTableViewController  * MEGoldController = [meST instantiateViewControllerWithIdentifier:@"goldST"];
//    WIFImodel *model=self.modelArr[2];
//    MEGoldController.model=model;
    __block GoldViewController *mainVC=self;
    //用__block修饰不会造成内存泄漏
    
    MEGoldController.Getblock=^(NSString *str){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            mainVC.gold_num.text=str;
        });
        
    };
    
    [self.navigationController pushViewController:MEGoldController animated:YES];
    
    
    
}

//好友排行
- (IBAction)rankAction:(UIButton *)sender {
    
    //[SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
    FirenfRankViewController *frVC=[[FirenfRankViewController alloc]init];
    
    [self.navigationController pushViewController:frVC animated:YES];
    
}

//摇一摇
- (IBAction)takeAction:(UIButton *)sender {
    
//    [SVProgressHUD showImage:nil status:@"功能暂未开通,敬请期待!"];
    
    if (self.modelArr.count>1) {
         BWShakeController *shakeVC=[[BWShakeController alloc]init];
        WIFImodel *model5=self.modelArr[5];
        shakeVC.model=model5;
        [self.navigationController pushViewController:shakeVC animated:YES];
    }
    
    
}

//应用下载
- (IBAction)downAction:(UIButton *)sender {
    
    self.tabBarController.selectedIndex = 2;
    
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
