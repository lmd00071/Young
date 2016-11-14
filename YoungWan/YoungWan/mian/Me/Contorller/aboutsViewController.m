//
//  aboutsViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/9/27.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "aboutsViewController.h"
#import "aboutTableViewCell.h"
#import "ExplainViewController.h"
@interface aboutsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tablesView;
@property (nonatomic, strong) BWHttpRequestManager *manager;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;

@end
static NSString *aboutCell=@"aboutCell";
@implementation aboutsViewController

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
    self.navigationItem.title=@"关于";
    [self.tablesView registerNib:[UINib nibWithNibName:@"aboutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:aboutCell];
    self.tablesView.scrollEnabled=NO;
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [self setupCancelSuccess];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
    
}

//每行显示什么样的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    aboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aboutCell];
    if (!cell) {
        cell = [[aboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aboutCell];
    }
    
    if (indexPath.row==0) {
        
        cell.iamgeView.hidden=YES;
        cell.titleLable.text=@"当前版本";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        cell.subLabel.text=version;
        
    }
    
    if (indexPath.row==1) {
    
         cell.titleLable.text=@"新版本检测";
    }
    if (indexPath.row==2) {
         cell.titleLable.text=@"注意事项";
    }
    
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
    return 44;
    
}


//cell的点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==1) {
        
        [self upgrade];
    }
    
    if (indexPath.row==2) {
        
        ExplainViewController *exVC=[[ExplainViewController alloc]init];
        exVC.titles=@"注意事项";
        exVC.subTitle=@"本APP内所有抽奖、竞猜及兑换等服务或活动,均由Young网络APP提供,与苹果公司无关.";
        [self.navigationController pushViewController:exVC animated:YES];
    }
}

- (void)upgrade
{
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSString *account =[user objectForKey:@"请输入手机号码"];
    [SVProgressHUD showWithStatus:@"正在检测中..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"upgrade";
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
                //[SVProgressHUD showImage:nil status:dict[@"error_string"]];
                self.backgroundView.hidden=NO;
                self.errorStringLabel.text=dict[@"error_string"];
            });
            
        } else {  //成功,
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dict[@"appv"] isEqualToString:@""]) {
                    
                    //[SVProgressHUD showImage:nil status:@"已经是最新版本"];
                    self.backgroundView.hidden=NO;
                    self.errorStringLabel.text=@"已经是最新版本";
                }else{
                    
                    //                    [SVProgressHUD showImage:nil status:[NSString stringWithFormat:@"最新版本号为%@",dict[@"appv"]]];
                    self.backgroundView.hidden=NO;
                    self.errorStringLabel.text=[NSString stringWithFormat:@"最新版本号为%@",dict[@"appv"]];
                    
                }
                
            });
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
