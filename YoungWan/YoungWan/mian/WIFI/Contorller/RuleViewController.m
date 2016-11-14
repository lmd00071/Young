//
//  RuleViewController.m
//  WidomStudy
//
//  Created by 李明丹 on 16/3/23.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "RuleViewController.h"
#import "PendulumView.h"
@interface RuleViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)PendulumView *pendulum;
@property (nonatomic,strong)UIWebView *webView;
@end
@implementation RuleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title = self.titleStr;
    self.navigationController.navigationBarHidden=NO;
    //设置成导航栏下面开始计算
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back32"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftAction:)];
    //判断当屏幕的高度是6P的时候
    CGFloat number6p=736;
    if ([UIScreen mainScreen].bounds.size.height>=number6p) {
        
           self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20-66)];
    }else{
           self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20-44)];
 
    }
 
    self.webView.delegate=self;
    //禁止拖深
    [(UIScrollView *)[[self.webView subviews]objectAtIndex:0]setBounces:NO];
    [self.view addSubview:self.webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.ruleUrl]];
    [self.webView loadRequest:request];
    
    UIColor *ballColor=[UIColor colorWithRed:0.47 green:0.60 blue:0.89 alpha:1];
    self.pendulum = [[PendulumView alloc] initWithFrame:self.view.bounds ballColor:ballColor ballDiameter:12];
    [self.view addSubview:self.pendulum];
    
    
}
#pragma mark - BarButtonItem 设置导航栏的左右点击方法
- (void)leftAction:(UIBarButtonItem *)sender
{

    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - webView 的协议方法
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //self.webView.userInteractionEnabled=NO;
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.pendulum stopAnimating];
    //self.webView.userInteractionEnabled=YES;
    
    
}
@end
