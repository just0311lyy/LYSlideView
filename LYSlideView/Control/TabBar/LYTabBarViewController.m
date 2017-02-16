//
//  LYTabBarViewController.m
//  LYSlideView
//
//  Created by MacBook on 2017/2/15.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import "LYTabBarViewController.h"
#import "LYMainViewController.h"
#import "LYTaskViewController.h"


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

@interface LYTabBarViewController ()

@end

@implementation LYTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithControllers];
}

-(void)initWithControllers{
    
    //UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LYMainViewController *roomVC = [[LYMainViewController alloc] init];
    UINavigationController *roomNav = [[UINavigationController alloc] initWithRootViewController:roomVC];
    roomNav.tabBarItem.title = @"房间";
    roomNav.tabBarItem.image = [[UIImage imageNamed:@"tab_home_click.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
    roomNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_unclick.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    LYTaskViewController *taskVC = [[LYTaskViewController alloc] init];
    UINavigationController *taskNav = [[UINavigationController alloc] initWithRootViewController:taskVC];
    taskNav.tabBarItem.title = @"定时";
    taskNav.tabBarItem.image = [[UIImage imageNamed:@"tab_time_click.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
    taskNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_time_unclick.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.viewControllers = @[roomNav,taskNav];
    self.selectedIndex = 0;
    //self.tabBar.backgroundColor = [UIColor lightGrayColor];
    //tabbar选中的颜色
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabBar_bg"]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : UIColorFromRGB(0x573500) }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
                                             forState:UIControlStateSelected];
    //---
    [UITabBar appearance].translucent = YES; //半透明
    [UITabBar appearance].clipsToBounds = YES; //显示出多余的
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
