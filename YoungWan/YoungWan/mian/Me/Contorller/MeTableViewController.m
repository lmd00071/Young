//
//  MeTableViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/11.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "MeTableViewController.h"
#import "LoginViewController.h"
#import "BindViewController.h"
#import "GoldViewController.h"
#import "aboutsViewController.h"
#import "ExplainViewController.h"
#import "UNBindViewController.h"
#import "BWPasswordController.h"
#import "changePassWorldViewController.h"
@interface MeTableViewController ()< UINavigationControllerDelegate,UIImagePickerControllerDelegate>
//图像
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
//绑定宽带
@property (strong, nonatomic) IBOutlet UILabel *bingNameLabel;
//名字
@property (strong, nonatomic) IBOutlet UILabel *user_phoneLable;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *errorStringLabel;


@property (nonatomic, strong) NSURLSessionDataTask *dnsTask;
@property (nonatomic, strong) NSURLSessionDataTask *csvTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask1;


@property (nonatomic, strong) NSURLSessionDataTask *userTask;
@property (nonatomic, strong) NSURLSessionDataTask *answerTask;
@property (nonatomic, strong) NSURLSessionDataTask *postTask;


//判断是否切换错误
@property (nonatomic,assign)BOOL account;
@property (nonatomic, strong) BWHttpRequestManager *manager;
//修改图像
@property (nonatomic, weak) UIView *hudView;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@end

@implementation MeTableViewController

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
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    
//    NSLog(@"前:user_account_uid=%@,bind_account=%@,user_account=%@,MD5PassWorld=%@,photo_raw_url=%@,",userMessage.user_account_uid,userMessage.bind_account,userMessage.user_account,userMessage.MD5PassWorld,userMessage.photo_raw_url);
    
    if(userMessage.user_account.length<=0){
        
       
    }else{
    
        self.user_phoneLable.text=userMessage.user_account_uid;
    
    }
    if (userMessage.bind_account) {
        
        if ([userMessage.bind_account isEqualToString:@""]||[userMessage.bind_account isEqualToString:@"(null)"]) {
            
            self.bingNameLabel.text=@"绑定宽带";
            
        }else{
        
        self.bingNameLabel.text=@"解除绑定";
            
        }
        
    }else{
        
         self.bingNameLabel.text=@"绑定宽带";
    
    }
    
    
    
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    self.tabBarController.navigationItem.titleView = [self titleView];
    self.navigationItem.title = @"我的";

    
   
}

- (void)viewDidDisappear:(BOOL)animated
{
   [ super viewDidDisappear:animated];
    
    [self.dnsTask cancel];
    [self.csvTask cancel];
    [self.userTask cancel];
    [self.answerTask cancel];
    [self.postTask cancel];
    [self.dataTask cancel];
    [self.dataTask1 cancel];
    [SVProgressHUD dismiss];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=HBRGBColor(235, 235, 241, 1);
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [self setupCancelLogin];
    [self setupCancelSuccess];
    //修改图像
    [self setupReviseIcon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//注销登录按钮的布局
- (void)setupCancelLogin
{
    self.tableView.bounces=NO;
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    UIButton *cancelbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelbtn.backgroundColor=HBRGBColor(245, 85, 30, 1);
    [cancelbtn setTitle:@"注销登录" forState:UIControlStateNormal];
    cancelbtn.titleLabel.font=[UIFont systemFontOfSize:17];
    cancelbtn.frame=CGRectMake(30, 0, HBScreenWidth-60, 40);
    cancelbtn.layer.cornerRadius=15;
    cancelbtn.clipsToBounds=YES;
    [cancelbtn addTarget:self action:@selector(cancelLogin:) forControlEvents:UIControlEventTouchUpInside];
    [cancelView addSubview:cancelbtn];
    self.tableView.tableFooterView = cancelView;
}

//注销的事件
- (void)cancelLogin:(UIButton *)sender
{
//    self.errorStringLabel.text=@"注销成功";
//    self.backgroundView.hidden=NO;
    
    
    [self outlogin];
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //账户信息
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        
        
    }
    
    //名称
    if (indexPath.section == 1 && indexPath.row == 0) {
        BWPasswordController *passwordController = [[BWPasswordController alloc] initWithNibName:@"BWPasswordController" bundle:[NSBundle mainBundle]];
        __block MeTableViewController *mainVC=self;
        //用__block修饰不会造成内存泄漏
        
        passwordController.changeNameblock=^(NSString *str){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *userArray=[NSMutableArray array];
                userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
                loginOrReginModel *userMessage = userArray.lastObject;
                
                    mainVC.user_phoneLable.text=[NSString stringWithFormat:@"%@(%@)",str,userMessage.user_account_uid];
            });
        };
        
        [self.navigationController pushViewController:passwordController animated:YES];
        
    }
    
    //修改头像
    if (indexPath.section == 1 && indexPath.row == 1) {
        
       self.hudView.hidden = NO;
    }
    
    //密码
    if (indexPath.section == 1 && indexPath.row == 2) {
        
        changePassWorldViewController *cpVC=[[changePassWorldViewController alloc]init];
        __block MeTableViewController *mainVC=self;
        //用__block修饰不会造成内存泄漏
        
        cpVC.changePassWorldblock=^(BOOL success){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success) {
                    [mainVC outlogin];
                }
            });
        };
        [self.navigationController pushViewController:cpVC animated:YES];
       
    }
    
    //绑定宽带
    if (indexPath.section == 1 && indexPath.row == 3) {
         //用__block修饰不会造成内存泄漏
          __block MeTableViewController *mainVC=self;
        //绑定宽带
        if ([mainVC.bingNameLabel.text isEqualToString:@"绑定宽带"]) {
            
            BindViewController *bVC=[[BindViewController alloc]init];
            bVC.bindblock=^(NSString *str){
                
                if ([str isEqualToString:@"绑定成功"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       mainVC.bingNameLabel.text=@"解除绑定";
                    });
                    
                }
                
            };
            [self.navigationController pushViewController:bVC animated:YES];
        }
        
           //解除绑定
        if ([mainVC.bingNameLabel.text isEqualToString:@"解除绑定"]) {
            
            UNBindViewController *unVC=[[UNBindViewController alloc]init];
            unVC.unbindblock=^(NSString *str){
                
                if ([str isEqualToString:@"解绑成功"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                       mainVC.bingNameLabel.text=@"绑定宽带";
                    });
                    
                }
            };
            [self.navigationController pushViewController:unVC animated:YES];
        }
        
    }
    
    //通知
    if (indexPath.section == 2 && indexPath.row == 0) {
        
        ExplainViewController *exVC=[[ExplainViewController alloc]init];
        exVC.titles=@"通知";
        [self.navigationController pushViewController:exVC animated:YES];
    }
    
    //新版本检测
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self upgrade];
       
    }
    
    //关于
    if (indexPath.section == 2 && indexPath.row == 2) {
        
      
          aboutsViewController * aboutController = [[aboutsViewController alloc]init];
        
        [self.navigationController pushViewController:aboutController animated:YES];
        
        
       
    }
}

//新版本检测
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 圆角弧度半径
    CGFloat cornerRadius = 6.f;
    // 设置cell的背景色为透明，如果不设置这个的话，则原来的背景色不会被覆盖
    cell.backgroundColor = UIColor.clearColor;
    
    // 创建一个shapeLayer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CAShapeLayer *backgroundLayer = [[CAShapeLayer alloc] init]; //显示选中
    // 创建一个可变的图像Path句柄，该路径用于保存绘图信息
    CGMutablePathRef pathRef = CGPathCreateMutable();
    // 获取cell的size
    // 第一个参数,是整个 cell 的 bounds, 第二个参数是距左右两端的距离,第三个参数是距上下两端的距离
    CGRect bounds = CGRectInset(cell.bounds, 10, 0);
    
    // CGRectGetMinY：返回对象顶点坐标
    // CGRectGetMaxY：返回对象底点坐标
    // CGRectGetMinX：返回对象左边缘坐标
    // CGRectGetMaxX：返回对象右边缘坐标
    // CGRectGetMidX: 返回对象中心点的X坐标
    // CGRectGetMidY: 返回对象中心点的Y坐标
    
    // 这里要判断分组列表中的第一行，每组section的第一行，每组section的中间行
    if ([tableView numberOfRowsInSection:indexPath.section]==1) {
        // 初始起点为cell的左下角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        
        
    }else{

    // CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        if (indexPath.row == 0) {
        // 初始起点为cell的左下角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        // 起始坐标为左下角，设为p，（CGRectGetMinX(bounds), CGRectGetMinY(bounds)）为左上角的点，设为p1(x1,y1)，(CGRectGetMidX(bounds), CGRectGetMinY(bounds))为顶部中点的点，设为p2(x2,y2)。然后连接p1和p2为一条直线l1，连接初始点p到p1成一条直线l，则在两条直线相交处绘制弧度为r的圆角。
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 终点坐标为右下角坐标点，把绘图信息都放到路径中去,根据这些路径就构成了一块区域了
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        // 初始起点为cell的左上角坐标
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        // 添加一条直线，终点坐标为右下角坐标点并放到路径中去
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        // 添加cell的rectangle信息到path中（不包括圆角）
        CGPathAddRect(pathRef, nil, bounds);
    }
    
    }
    // 把已经绘制好的可变图像路径赋值给图层，然后图层根据这图像path进行图像渲染render
    layer.path = pathRef;
    backgroundLayer.path = pathRef;
    // 注意：但凡通过Quartz2D中带有creat/copy/retain方法创建出来的值都必须要释放
    CFRelease(pathRef);
    // 按照shape layer的path填充颜色，类似于渲染render
    // layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    // view大小与cell一致
    UIView *roundView = [[UIView alloc] initWithFrame:bounds];
    // 添加自定义圆角后的图层到roundView中
    [roundView.layer insertSublayer:layer atIndex:0];
    roundView.backgroundColor = UIColor.clearColor;
    // cell的背景view
    cell.backgroundView = roundView;
    
    // 以上方法存在缺陷当点击cell时还是出现cell方形效果，因此还需要添加以下方法
    // 如果你 cell 已经取消选中状态的话,那以下方法是不需要的.
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:bounds];
    backgroundLayer.fillColor = [UIColor cyanColor].CGColor;
    [selectedBackgroundView.layer insertSublayer:backgroundLayer atIndex:0];
    selectedBackgroundView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectedBackgroundView;
    
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

//网络请求
- (void)outlogin
{
    
    [SVProgressHUD showWithStatus:@"正在注销..."];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"trans_code"] = @"user_logout";
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
                
                //清空用户信息
                NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '',  bind_account='', user_account='', MD5PassWorld=''"];
                
                [LoginUserManager modifyData:modifyString];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //退出登录通知
                    NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
                    [notiCenter postNotificationName:@"ouylogin" object:self userInfo:nil];
                    
                    [SVProgressHUD showSuccessWithStatus:@"注销成功"];
                    
                    for (UINavigationController *navVc in self.tabBarController.childViewControllers) {
                        
                        UIViewController *vc = navVc.childViewControllers.firstObject;
                        
                        LoginViewController *loginC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
                        
                        if ([vc isKindOfClass:[GoldViewController class]]) {
                        
                            [vc.navigationController pushViewController:loginC animated:YES];
                        }
                        
                        if ([vc isKindOfClass:[MeTableViewController class]]) {
                            
                            [vc.navigationController pushViewController:loginC animated:YES];
                        }
                    }
                    
                });
            }
        }];
        [csvTask resume];
        weakself.csvTask = csvTask;
        
        
    }];
    [dnsTask resume];
    self.dnsTask=dnsTask;
    
}



- (void)setupReviseIcon
{
    UIView *hudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudDismiss)];
    [hudView addGestureRecognizer:tap];
    hudView.hidden = YES;
    self.hudView = hudView;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, HBScreenHeight - 130, HBScreenWidth, 130)];
    contentView.backgroundColor = [UIColor whiteColor];
    [hudView addSubview:contentView];
    
    NSArray *titleArray = @[@"拍照", @"选择本地图片", @"取消"];
    CGFloat btnW = contentView.bw_width - 2 * BWMargin;
    CGFloat btnH = 30;
    CGFloat btnX = BWMargin;
    CGFloat btnY = BWMargin;
    
    for (int i = 0; i < titleArray.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn setBackgroundColor:HBConstColor];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        if (i == 0) {
            [btn addTarget:self action:@selector(photographClick) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 1) {
            [btn addTarget:self action:@selector(choosePhotoClick) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 2) {
            [btn addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
        }
        [contentView addSubview:btn];
        
        btnY += (btnH + BWMargin);
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:hudView];
}

- (void)hudDismiss
{
    self.hudView.hidden = YES;
}

//拍照点击事件
- (void)photographClick
{
    self.hudView.hidden = YES;
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//选择本地图片点击事件
- (void)choosePhotoClick
{
    self.hudView.hidden = YES;
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//修改头像界面的取消按钮的点击事件
- (void)cancelChoose
{
    self.hudView.hidden = YES;
}

//懒加载imagePickerController
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        _imagePicker = imagePicker;
    }
    return _imagePicker;
}

//选择图片后调用的方法
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.userImageView.image=image;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    [SVProgressHUD showWithStatus:@"正在上传图片..."];
    
    //拿到用户信息
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"trans_code"] = @"user_info_set";
    parameters[@"yc_user_role"] = @"none";
    
    NSString *xmlString = [parameters newXMLString];
    
    NSMutableURLRequest *dnsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BWBaseUrlString]];
    
    [dnsRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    dnsRequest.HTTPBody = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    dnsRequest.HTTPMethod = @"POST";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    __weak typeof(self) weakself = self;
    
    //获取上传地址的请求
    NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:dnsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"获取地址失败"];
            });
            return;
        }
        NSDictionary *dnsDict = [NSDictionary dictionaryWithXMLData:data];
        NSMutableString *dnsString = dnsDict[@"dns.url"];
        NSRange range = [dnsString rangeOfString:@".aspx"];
        if (range.length) {
            [dnsString insertString:@"_upload" atIndex:(range.location)];
        }
        
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsString]];
        
        [postRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        postRequest.HTTPBody = imageData;
        postRequest.HTTPMethod = @"POST";
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //上传文件
            NSURLSessionDataTask *postTask = [session dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"上传头像失败"];
                        self.userImageView.image=[UIImage imageNamed:@"setting_default_head-1"];
                    });
                    
                    return;
                }
                
                NSDictionary *postDict = [NSDictionary dictionaryWithXMLData:data];
                NSString *subString = postDict[@"receipt.receipt"];
                ////
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
                parameter[@"user_name"] = @"";
                parameter[@"user_email"] = @"";
                parameter[@"user_msisdn"] = @"";
                parameter[@"upload_receipt_photo"] = subString;
        
                NSDate *date = [NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyyMMddHHmmss"];
                NSString *dateString = [formatter stringFromDate:date];
                NSString *fileName = [NSString stringWithFormat:@"%@.png",dateString];
                parameter[@"upload_photo_file"] = fileName;
               
                NSMutableArray *userArray=[NSMutableArray array];
                userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
                loginOrReginModel *userMessage = userArray.lastObject;
                if(userMessage.user_account.length>0){
                    
                    parameter[@"yc_msisdn"] = userMessage.user_account_uid;
                    
                }
                
                /////
                NSString *dataXmlString = [parameter newXMLString];
        
                NSString *answerString = [dnsString stringByReplacingOccurrencesOfString:@"_upload" withString:@""];
                NSMutableURLRequest *answerRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:answerString]];
                [answerRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                NSStringToBetyArray *tool=[[NSStringToBetyArray alloc]init];
                answerRequest.HTTPBody = [tool encryptString:dataXmlString];
                answerRequest.HTTPMethod = @"POST";
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //将上传的头像告诉中控
                    NSURLSessionDataTask *answerTask = [session dataTaskWithRequest:answerRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showImage:nil status:@"中控拉取头像失败"];
                                self.userImageView.image=[UIImage imageNamed:@"setting_default_head-1"];
                                
                            });
                            
                            return;
                        }
                        
                        NSDictionary *schoolDict = [NSDictionary dictionaryWithXMLData:data];
                        
                        if (schoolDict[@"error_code"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [SVProgressHUD showImage:nil status:schoolDict[@"error_string"]];
                                self.userImageView.image=[UIImage imageNamed:@"setting_default_head-1"];
                            });
                            return;
                        }
                        
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                            [SVProgressHUD showImage:nil status:@"修改成功"];
                            weakself.userImageView.image=image;
                            
//                            NSMutableDictionary *para = [NSMutableDictionary dictionary];
//                            
//                            para[@"trans_code"] = @"user_info_get";
//                            para[@"from_system"] = FromSystem;
//                            //拿到手机的MAC地址
//                            para[@"from_client_id"] = AppUUID;
//                            //拿到当前版本号
//                            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//                            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//                            para[@"from_client_version"] = version;
//                            
//                            para[@"yc_user_account_uid"] = userMessage.user_account_uid;
//                            //                                    para[@"yc_school_id"] = userMessage.school_id;
//                            //                                    para[@"yc_dept_id"] = userMessage.dept_id;
//                            //登录成功,请求用户信息
//                            NSString *requestString = [para newXMLString];
//                            
//                            NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:answerString]];
//                            
//                            [userRequest addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//                            userRequest.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
//                            userRequest.HTTPMethod = @"POST";
//                            
//                            NSURLSessionDataTask *userTask = [session dataTaskWithRequest:userRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                                
//                                if (error) {
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [SVProgressHUD showErrorWithStatus:@"请求失败..."];
//                                    });
//                                    return;
//                                }
//                                
//                                NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLData:data];
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    
//                                    NSString *user_accout_uid = xmlDict[@"user_account_uid"];
//                                    if (user_accout_uid.length > 0) {
//                                        [SVProgressHUD showSuccessWithStatus:@"修改头像成功"];
//                                        
//                                        for (UINavigationController *navVc in weakself.tabBarController.childViewControllers) {
//                                            
//                                            if (navVc.childViewControllers.count > 1) {
//                                                
//                                                [navVc popViewControllerAnimated:YES];
//                                            }
//                                        }
//                                        
//                                        //将用户数据存到数据库中
//                                        loginOrReginModel *model = [loginOrReginModel mj_objectWithKeyValues:xmlDict];
//                                        //                                                model.account =  userMessage.account;
//                                        //                                                model.password = userMessage.password;
//                                        NSMutableArray *userArray=[NSMutableArray array];
//                                        userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
//                                        if (userArray.count > 0) {
////                                            NSString *modifyString = [NSString stringWithFormat:@"UPDATE loginUser SET user_account_uid = '%@',  user_name='%@', user_msisdn='%@', photo_icon_url='%@', photo_raw_url='%@'", model.user_account_uid, model.user_name, model.user_msisdn, model.photo_icon_url, model.photo_raw_url];
//                                            //[LoginUserManager modifyData:modifyString];
////                                            [weakself.IconImageView sd_setImageWithURL:[NSURL URLWithString:model.photo_icon_url] placeholderImage:[UIImage imageNamed:@"setting_default_head"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
////                                                weakself.IconImageView.image = image;
////                                            }];
//                                        } else {
////                                            [LoginUserManager insertModal:model];
//                                        }
//                                    } else {
//                                        [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
//                                    }
//                                });
//                            }];
//                            [userTask resume];
//                            self.userTask=userTask;
                        });
                    }];
                    //                            [schoolTask resume];
                    //});
                    //}];
                    [answerTask resume];
                    self.answerTask=answerTask;
                });
            }];
            [postTask resume];
            self.postTask=postTask;
        });
    }];
    [dnsTask resume];
    self.dnsTask=dnsTask;
}



@end
