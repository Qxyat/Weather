//
//  UITableViewController+BaseTableViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "UITableViewController+BaseTableViewController.h"
#import <AFNetworking.h>
@implementation UITableViewController (BaseTableViewController)
-(void)showLoading{
    UIView *loading=[[NSBundle mainBundle]loadNibNamed:@"Loading" owner:nil options:nil][0];
    loading.frame=CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [[UIApplication sharedApplication].keyWindow addSubview:loading];
}
-(void)hideLoading{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:1] removeFromSuperview];
    [self.tableView reloadData];
}
-(void)showError{
    UIView *error=[[NSBundle mainBundle]loadNibNamed:@"Error" owner:nil options:nil][0];
    error.frame=CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [[UIApplication sharedApplication].keyWindow addSubview:error];
    UILabel *errorLabel=[error viewWithTag:1];
    NSLog(@"%d",[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus);
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        errorLabel.text=@"请检查您的网络连接!";
    }
    else{
        errorLabel.text=@"服务器开小差了";
    }
    UIButton *errorButton=[error viewWithTag:2];
    [errorButton addTarget:self action:@selector(hideError) forControlEvents:UIControlEventTouchUpInside];
}
-(void)hideError{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:3]removeFromSuperview];
    [self loadData];
}
-(void)loadData{
}
@end
