//
//  WeatherViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/8.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "WeatherViewController.h"
#import <AFNetworking.h>
@interface WeatherViewController()
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;


@end
@implementation WeatherViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadWeatherDataFromServer];
}
-(void)loadWeatherDataFromServer{
    [self showLoading];
    NSString * request=[@"http://wthrcdn.etouch.cn/weather_mini?citykey=101**" stringByReplacingOccurrencesOfString:@"**" withString:self.countyId];
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFJSONResponseSerializer alloc]init];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"text/plain", @"text/html",nil];
    [manager GET:request parameters:nil success:
        ^(AFHTTPRequestOperation *operation,id response){
            self.temperatureLabel.text=[NSString stringWithFormat:@"%@",response[@"data"][@"wendu"]];
            [self hideLoading];
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            NSLog(@"%@",error);
            [self showError];
        }];
}
-(void)showLoading{
    UIView *loading=[[NSBundle mainBundle]loadNibNamed:@"Loading" owner:nil options:nil][0];
    loading.frame=CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [[UIApplication sharedApplication].keyWindow addSubview:loading];
}
-(void)hideLoading{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:1] removeFromSuperview];
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
    [self loadWeatherDataFromServer];
}

@end