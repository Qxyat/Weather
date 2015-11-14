//
//  WeatherViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/8.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "WeatherViewController.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import "AppDelegate.h"
@interface WeatherViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *weatherScrollView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong,nonatomic) UIPopoverController *popoverController;
@property (strong,nonatomic) UIAlertController *alertController;

@property (strong,nonatomic) UIView *middleView;
@property (strong,nonatomic) UIView *shareMediaView;
@end
@implementation WeatherViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.countyId=@"";
    self.weatherScrollView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadWeatherDataFromServer)];
    [self refreshView];
}
-(void)refreshView{
    [self.weatherScrollView.mj_header beginRefreshing];
}
-(void)loadWeatherDataFromServer{
    //[self showLoading];
    NSString * request=[@"http://www.weather.com.cn/data/cityinfo/101**.html" stringByReplacingOccurrencesOfString:@"**" withString:self.countyId];
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFHTTPResponseSerializer alloc]init];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"text/plain", @"text/html",@"text/xml",nil];
    [manager GET:request parameters:nil success:
     ^(AFHTTPRequestOperation *operation,id response){
         NSString *text=[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
         self.temperatureLabel.text=text;
         [self.weatherScrollView.mj_header endRefreshing];
     } failure:^(AFHTTPRequestOperation *operation,NSError *error){
         NSLog(@"%@",error);
         //[self showError];
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

#pragma mark - 展示分享窗口
- (IBAction)shareMediaButtonPressed:(id)sender{
    self.middleView=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.middleView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.middleView.alpha=0.5;
    [self.view addSubview:self.middleView];
    
    NSArray *array=[[NSBundle mainBundle] loadNibNamed:@"shareMediaView" owner:self options:nil];
    self.shareMediaView=[array lastObject];
    int x=CGRectGetMidX([UIScreen mainScreen].bounds)-self.shareMediaView.frame.size.width/2;
    int y=CGRectGetMidY([UIScreen mainScreen].bounds)-self.shareMediaView.frame.size.height/2;
    [self.shareMediaView setFrame:CGRectMake(x, y, self.shareMediaView.frame.size.width, self.shareMediaView.frame.size.height)];
    self.shareMediaView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.01];
    [self.view addSubview:self.shareMediaView];
    
    UIButton *cancleButton=[self.shareMediaView viewWithTag:10];
    [cancleButton addTarget:self action:@selector(cancleShareMedia) forControlEvents:UIControlEventTouchUpInside];
 
    UIButton *shareWXSessionButton=[self.shareMediaView viewWithTag:1];
    [shareWXSessionButton addTarget:self action:@selector(shareToWXSession) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareWXTimeLineButton=[self.shareMediaView viewWithTag:2];
    [shareWXTimeLineButton addTarget:self action:@selector(shareToWXTimeLine) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareToWXSession {
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setWXScene:0];
    [appDelegate sendTextContent];
}
- (void)shareToWXTimeLine{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setWXScene:1];
    [appDelegate sendTextContent];

}
-(void)cancleShareMedia{
    [self.middleView removeFromSuperview];
    [self.shareMediaView removeFromSuperview];
}

@end
