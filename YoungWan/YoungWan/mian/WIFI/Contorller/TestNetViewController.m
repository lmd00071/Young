//
//  TestNetViewController.m
//  YoungWan
//
//  Created by 李明丹 on 16/9/1.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "TestNetViewController.h"
#import "SCChart.h"
#import "STDebugFoundation.h"
#import "STDPingServices.h"
@interface TestNetViewController ()

//开始按键距离底部的距离
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *startButtonBottomConstaint;

//开始的高度
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *stratButtonConstraint;

@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *webLable;

@property (nonatomic,assign)NSInteger number;
//测试按键
@property (strong, nonatomic) IBOutlet UIButton *stratButton;
@property(nonatomic, strong) STDPingServices    *pingServices;
//网址
@property (nonatomic,strong)NSArray *webArr;
@property (nonatomic,strong)NSArray *forMatStr;

@property (atomic,strong) NSCondition *condition;

//设置定时器
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation TestNetViewController

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
    
      [SVProgressHUD dismiss];
    
    self.view.backgroundColor=HBRGBColor(230, 231, 233, 1);
    self.navigationItem.title=@"网页测试";
    //4s的情况下
    CGFloat number4=480;
    if ([UIScreen mainScreen].bounds.size.height==number4) {
        
        self.stratButtonConstraint.constant=30;
        self.startButtonBottomConstaint.constant=20;
    
    }
    
    self.webArr=[NSArray array];
    self.webArr=@[@"www.163.com",@"www.tudou.com",@"www.baidu.com",@"123.sogou.com",@"www.QQ.com",@"www.sina.com.cn",@"t.sina.com.cn",@"www.damai.cn",@"www.taobao.com",@"www.jd.com",@"www.youku.com"];
    self.forMatStr=[NSArray array];
    self.forMatStr=@[@"网易",@"土豆",@"百度",@"搜狗",@"腾讯",@"新浪",@"新浪微博",@"其他",@"淘宝",@"京东",@"优酷"];
    self.number=0;
    [self setChart];
    _condition=[[NSCondition alloc]init];
    
}


- (IBAction)startAction:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"开始测试"] ) {
        [sender setTitle:@"停止测试" forState:UIControlStateNormal];
        self.startLabel.text=@"测试中...";
        self.number=0;
        [self testAction];

    }
    
    if ([sender.titleLabel.text isEqualToString:@"停止测试"] ) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.pingServices cancel];
        self.pingServices=nil;
        [sender setTitle:@"重新测试" forState:UIControlStateNormal];
        self.startLabel.text=@"测试停止";
        
    }
      
    if ([sender.titleLabel.text isEqualToString:@"重新测试"] ) {
            [sender setTitle:@"停止测试" forState:UIControlStateNormal];
            self.startLabel.text=@"测试中...";
        if (self.number==11) {
            self.number=10;
        }
        for (int i=0; i<self.number+1; i++) {
            SCCircleChart *chartView=[self.view viewWithTag:(100000+i)];
            [chartView updateChartByCurrent:@0];
            chartView.format = self.forMatStr[i];
            [chartView strokeChart];
            
        }
        self.number=0;
        [self testAction];
      
    }
    
}

//循环测试
- (void)testAction{

    if (self.number>=self.webArr.count) {
        
        return;
    }
            __weak TestNetViewController *weakSelf = self;
            self.pingServices = [STDPingServices startPingAddress:self.webArr[self.number] callbackHandler:^(STDPingItem *pingItem, NSArray *pingItems) {
                
                if (pingItem.status != STDPingStatusFinished) {
                    
                    if (pingItem.status==STDPingStatusDidReceivePacket) {
                        
                        if (weakSelf.number>=weakSelf.webArr.count) {
                        
                            [weakSelf.pingServices cancel];
                            weakSelf.pingServices=nil;
                            [weakSelf.stratButton setTitle:@"重新测试" forState:UIControlStateNormal];
                            weakSelf.startLabel.text=@"测试停止";
                            return;
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.webLable.text=[NSString stringWithFormat:@"http://%@/",weakSelf.webArr[weakSelf.number]];
                            SCCircleChart *chartView=[weakSelf.view viewWithTag:(100000+weakSelf.number)];
                            [chartView updateChartByCurrent:@100];
                            
                            NSString *suStr=[NSString stringWithFormat:@"%.3fKB/S",(pingItem.dateBytesLength/1024.0)/(pingItem.timeMilliseconds/1000.0)];
                            chartView.format = [NSString stringWithFormat:@"%@\n%@",suStr,weakSelf.forMatStr[weakSelf.number]];
                            [chartView strokeChart];
                            [weakSelf.pingServices cancel];
                            weakSelf.pingServices=nil;
                            weakSelf.number++;
                            return ;
                        });
                    }else{
                        [weakSelf.pingServices cancel];
                        weakSelf.pingServices=nil;
                        return ;
                    }

                    
                } else {
                    
                    weakSelf.pingServices=nil;
                    return ;
                    
                    
                }
                //继续测试
                
            }];
            

}

- (void)setChart
{
    
    NSArray *image=@[@"web_163",@"web_tudou",@"web_baidu",@"web_sougou",@"web_qq",@"web_sina",@"web_sina_weibo",@"web_other",@"web_taobao",@"web_jingdong",@"web_youku"];
    
    
    for (int i=0; i<11; i++) {
        
        //判断当屏幕的高度是6P的时候
        CGFloat number4=480;
        if ([UIScreen mainScreen].bounds.size.height==number4) {
            
            SCCircleChart *chartView = [[SCCircleChart alloc] initWithFrame:CGRectMake((HBScreenWidth-240)/5+i%4*(60+(HBScreenWidth-240)/5), 60+i/4*100, 60.0, 60.0) total:@100 current:@0 clockwise:YES];
            [chartView setStrokeColor:[UIColor greenColor]];
            chartView.userInteractionEnabled=YES;
            chartView.tag=100000+i;
            chartView.chartType = SCChartFormatTypeNone;
            chartView.format = self.forMatStr[i];
            chartView.imageName=image[i];
            [chartView strokeChart];
            [self.view addSubview:chartView];
            
            
        }else{
        
            SCCircleChart *chartView = [[SCCircleChart alloc] initWithFrame:CGRectMake((HBScreenWidth-240)/5+i%4*(60+(HBScreenWidth-240)/5), 70+i/4*120, 60.0, 60.0) total:@100 current:@0 clockwise:YES];
            [chartView setStrokeColor:[UIColor greenColor]];
            chartView.userInteractionEnabled=YES;
            chartView.tag=100000+i;
            chartView.chartType = SCChartFormatTypeNone;
            chartView.format = self.forMatStr[i];
            chartView.imageName=image[i];
            [chartView strokeChart];
            [self.view addSubview:chartView];
        
        }
        
    
        
    }
    
}

- (void)dealloc {
    [self.pingServices cancel];
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
