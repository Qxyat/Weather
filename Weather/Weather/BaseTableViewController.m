//
//  UITableViewController+BaseTableViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BaseTableViewController.h"
#import <AFNetworking.h>
@implementation BaseTableViewController
-(void)setNavigationTitle:(NSString *)title{
    CGSize maxSize=CGSizeMake(300, 1000);
    NSStringDrawingOptions opts=NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    NSDictionary *attributes=@{NSFontAttributeName:[self defaultFont]};
    CGRect rect=[title boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
    float titleLabelX=CGRectGetWidth([UIScreen mainScreen].bounds)*0.667-CGRectGetWidth(rect)+10;
    rect.origin=CGPointMake(titleLabelX, 32);
    UILabel *textLabel=[[UILabel alloc]initWithFrame:rect];
    textLabel.text=title;
    [textLabel setTag:100];
    [self.navigationController.view addSubview:textLabel];
}

-(UIFont *)defaultFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

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
