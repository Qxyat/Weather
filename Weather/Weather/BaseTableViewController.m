//
//  UITableViewController+BaseTableViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BaseTableViewController.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "WeatherViewController.h"
#import <TSMessage.h>
extern NSString * kName;
extern NSString * kId;
static NSString * const kLocateCity=@"locateCity";
@interface BaseTableViewController ()

@property (strong,nonatomic)CLLocationManager *locationManager;
@property (strong,nonatomic)NSString * locateCity;
@property (strong,nonatomic)UILabel *locateCityLabel;
@property (strong,nonatomic)UIView * loadingView;
@property (strong,nonatomic)UIView * errorView;

@end

@implementation BaseTableViewController
#pragma mark - 加载通用的视图
-(void)viewDidLoad{
    [super viewDidLoad];
    float width=CGRectGetWidth([UIScreen mainScreen].bounds)*0.667;
    _searchController=[[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchBar.bounds=CGRectMake(0, 0, width, 40);
    _searchController.searchResultsUpdater=self;
    _searchController.hidesNavigationBarDuringPresentation=NO;
    _searchController.dimsBackgroundDuringPresentation=NO;
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, width, CGRectGetHeight([UIScreen mainScreen].bounds))];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellPCC"];
    [self.tableView registerNib:[UINib nibWithNibName:@"locateCell" bundle:nil] forCellReuseIdentifier:@"cellLocate"];
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    [self.view addSubview:self.tableView];
    
    self.locateCity=[self getUserDefaultsLocateCity];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.searchController.active=NO;
    [super viewWillDisappear:animated];
}

#pragma mark - 设置导航的标题
-(void)setNavigationTitle:(NSString *)title{
    CGSize maxSize=CGSizeMake(300, 1000);
    NSStringDrawingOptions opts=NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    NSDictionary *attributes=@{NSFontAttributeName:[self defaultFont]};
    CGRect rect=[title boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
    float titleLabelX=CGRectGetWidth([UIScreen mainScreen].bounds)*0.667-CGRectGetWidth(rect)+10;
    rect.origin=CGPointMake(titleLabelX, 32);
    UILabel *textLabel=[[UILabel alloc]initWithFrame:rect];
    textLabel.text=title;
    [self.navigationController.view addSubview:textLabel];
}
-(UIFont *)defaultFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark - 加载或错误提示
-(void)showLoading{
    self.loadingView=[[NSBundle mainBundle]loadNibNamed:@"Loading" owner:nil options:nil][0];
    self.loadingView.frame=CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadingView];
}
-(void)hideLoading{
    [self.loadingView removeFromSuperview];
    
    [self.tableView reloadData];
}

-(void)showError{
    self.errorView=[[NSBundle mainBundle]loadNibNamed:@"Error" owner:nil options:nil][0];
    self.errorView.frame=CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [[UIApplication sharedApplication].keyWindow addSubview:self.errorView];
    UILabel *errorLabel=[self.errorView viewWithTag:1];
    NSLog(@"%ld",(long)([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus));
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        errorLabel.text=@"请检查您的网络连接!";
    }
    else{
        errorLabel.text=@"服务器开小差了";
    }
    UIButton *errorButton=[self.errorView viewWithTag:2];
    [errorButton addTarget:self action:@selector(hideError) forControlEvents:UIControlEventTouchUpInside];
}
-(void)hideError{
    [self.errorView removeFromSuperview];
    [self loadData];
}

#pragma mark - 子类必须实现的数据加载的方法
-(void)loadData{
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    
    if(!self.searchController.active){
        if(indexPath.section==0){
            cell=[self.tableView dequeueReusableCellWithIdentifier:@"cellLocate"];
            UIButton *button=[cell viewWithTag:1];
            [button addTarget:self action:@selector(locate) forControlEvents:UIControlEventTouchUpInside];
            self.locateCityLabel=[cell viewWithTag:2];
            if(self.locateCity==nil){
                [self locate];
            }
            else{
                self.locateCityLabel.text=self.locateCity;
            }
        }
        else{
            cell=[self.tableView dequeueReusableCellWithIdentifier:@"cellPCC"];
            cell.textLabel.text=[dataList[indexPath.row] valueForKey:kName];
            cell.detailTextLabel.text=[dataList[indexPath.row] valueForKey:kId];
        }
    }
    else{
        cell=[self.tableView dequeueReusableCellWithIdentifier:@"cellPCC"];
        cell.textLabel.text=[searchResult[indexPath.row] valueForKey:kName];
        cell.detailTextLabel.text=[searchResult[indexPath.row] valueForKey:kId];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.searchController.active){
        if(section==0)
            return 1;
        else
            return dataList.count;
    }
    else
        return searchResult.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!self.searchController.active)
        return 2;
    else
        return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(!self.searchController.active){
        if(section==0)
            return @"定位";
        else
            return @"区域列表";
    }
    else{
        return nil;
    }
}

#pragma mark - 获取先前已经定位过的城市
-(NSString *)getUserDefaultsLocateCity{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kLocateCity];
}

#pragma mark - 保存定位到的城市
-(void)saveUserDefaultsLocateCity{
    [[NSUserDefaults standardUserDefaults] setValue:self.locateCity forKey:kLocateCity];
}

#pragma mark - 展示定位城市的天气
-(void)showLocatedCityWeather{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    WeatherViewController *controller=(WeatherViewController*)appDelegate.deckViewController.centerController;
    controller.cityName=self.locateCity;
    controller.refreashWay=0;
    [controller refreshView];
}

#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    searchResult=[[NSMutableArray alloc]init];
    NSString *searchString=self.searchController.searchBar.text;
    if(searchString.length>0){
        NSPredicate *predicate=[NSPredicate predicateWithBlock:
                                ^BOOL(NSDictionary* item,NSDictionary *b){
                                    NSRange range=[item[kName] rangeOfString:searchString];
                                    return range.location!=NSNotFound;
                                }];
        NSArray *matches=[dataList filteredArrayUsingPredicate:predicate];
        [searchResult addObjectsFromArray:matches];
    }
    [self.tableView reloadData];
}

#pragma mark - Location
-(void)locate{
    self.locateCityLabel.text=@"正在定位中...";
    if([CLLocationManager locationServicesEnabled]){
        self.locationManager=[[CLLocationManager alloc]init];
        self.locationManager.delegate=self;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=1000;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }else{
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"请确保打开定位" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOpenLocation=[UIAlertAction actionWithTitle:@"前去打开定位" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     NSURL *url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                 }];
        UIAlertAction *actionCancleLocation=[UIAlertAction actionWithTitle:@"暂不打开定位" style:UIAlertActionStyleCancel
                                                                   handler:^(UIAlertAction * _Nonnull action){
                                                                       self.locateCity=nil;
                                                                       self.locateCityLabel.text=@"定位失败";
                                                                   }];
        [controller addAction:actionOpenLocation];
        [controller addAction:actionCancleLocation];
        [self presentViewController:controller animated:YES completion:nil];
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location=[locations lastObject];
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error!=nil){
            self.locateCity=nil;
            self.locateCityLabel.text=@"定位失败";
        }
        if (placemarks.count>0) {
            CLPlacemark *placeMark=[placemarks objectAtIndex:0];
            self.locateCity=placeMark.locality;
            if(self.locateCity==nil){
                self.locateCity=placeMark.administrativeArea;
            }
            self.locateCity=[self.locateCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
            [self saveUserDefaultsLocateCity];
            [self.tableView reloadData];
        }
    }
     ];
    [manager stopUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.locateCity=nil;
    self.locateCityLabel.text=@"定位失败";
}
@end
