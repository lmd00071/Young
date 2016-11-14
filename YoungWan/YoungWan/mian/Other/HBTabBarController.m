//
//  HBTabBarController.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/11.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "HBTabBarController.h"
#import "HBNavigationController.h"
#import "WIFIViewController.h"
#import "MeTableViewController.h"
#import "LoginViewController.h"
#import "DownViewController.h"
#import "GoldViewController.h"
@interface HBTabBarController ()

@end

@implementation HBTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.tabBar.barTintColor = [UIColor blueColor];
    
    [self setupChildViewControllers];
}
//设置所有的子控制器
- (void)setupChildViewControllers
{
    //WIFI
    WIFIViewController *WIFIController = [[WIFIViewController alloc] init];
    [self setupChildViewControllerWithViewController:WIFIController pushViewController:nil image:[UIImage imageNamed:@"tabbar_item_wifi_normal"] selectedImage:[[UIImage imageNamed:@"tabbar_item_wifi_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"WIFI"];
    
    NSMutableArray *userArray=[NSMutableArray array];
    userArray = [LoginUserManager queryData:@"SELECT * FROM loginUser"];
    loginOrReginModel *userMessage = userArray.lastObject;
    
    LoginViewController *loginVC1=nil;
    if(userMessage.user_account.length>0){
        
    }else{
    
        loginVC1 = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    }
    //赚金币
    GoldViewController *GoldController = [[GoldViewController alloc] init];
    [self setupChildViewControllerWithViewController:GoldController pushViewController:loginVC1 image:[UIImage imageNamed:@"tabbar_item_gold_normal"] selectedImage:[[UIImage imageNamed:@"tabbar_item_gold_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"赚金币"];
    
    
    
    //下载
    DownViewController *DownController = [[DownViewController alloc] init];
    [self setupChildViewControllerWithViewController:DownController pushViewController:nil image:[UIImage imageNamed:@"tabbar_item_app_normal"] selectedImage:[[UIImage imageNamed:@"tabbar_item_app_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"下载"];
    
    
    LoginViewController *loginVC2=nil;
    if(userMessage.user_account.length>0){
        
    }else{
        
        loginVC2 = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    }
    //创建Storyboard
    UIStoryboard *meST=[UIStoryboard storyboardWithName:@"MeViewController" bundle:[NSBundle mainBundle]];
    //我的
    //第一个参数是上面创建的,第二个是storyboard ID
    MeTableViewController  *MEAndSchoolController = [meST instantiateViewControllerWithIdentifier:@"meST"];
    [self setupChildViewControllerWithViewController:MEAndSchoolController pushViewController:loginVC2 image:[UIImage imageNamed:@"tabbar_item_my_normal"] selectedImage:[[UIImage imageNamed:@"tabbar_item_my_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"我的"];
    
}

//设置单个的子控制器
- (void)setupChildViewControllerWithViewController:(UIViewController *)viewController pushViewController:(UIViewController *)pushViewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title
{
    viewController.tabBarItem.image = image;
    viewController.tabBarItem.selectedImage = selectedImage;
    viewController.tabBarItem.title = title;
    NSDictionary *normalDictionary = @{NSForegroundColorAttributeName : HBConstColor};
    [viewController.tabBarItem setTitleTextAttributes:normalDictionary forState:UIControlStateNormal];
    NSDictionary *selectedDictionary = @{NSForegroundColorAttributeName : HBConstColor};
    [viewController.tabBarItem setTitleTextAttributes:selectedDictionary forState:UIControlStateSelected];
    
    HBNavigationController *navigationController = [[HBNavigationController alloc] initWithRootViewController:viewController];
    
    [self addChildViewController:navigationController];
    
    if (pushViewController) {
        [viewController.navigationController pushViewController:pushViewController animated:YES];
    }
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
