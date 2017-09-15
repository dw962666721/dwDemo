//
//  BlackNavViewController.m
//  DaiShengInvest
//
//  Created by 张睿 on 2017/6/28.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import "BlackNavViewController.h"

@interface BlackNavViewController ()


@end

@implementation BlackNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = ColorWithRGB(0x242424);
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (BOOL) shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}
- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
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
