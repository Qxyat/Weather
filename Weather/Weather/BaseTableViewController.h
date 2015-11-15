//
//  UITableViewController+BaseTableViewController.h
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface BaseTableViewController:UIViewController<UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *dataList;
    NSMutableArray *searchResult;
    NSString *kId;
    NSString *kName;
}
-(void)showLoading;
-(void)hideLoading;
-(void)showError;
-(void)hideError;

-(void)setNavigationTitle:(NSString *)title;

-(void)showLocatedCityWeather;
@property (strong,nonatomic)UISearchController *searchController;
@property (strong,nonatomic)UITableView *tableView;
@end
