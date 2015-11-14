//
//  UITableViewController+BaseTableViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "BaseTableViewController.h"
#import <AFNetworking.h>

extern NSString * kName;
extern NSString * kId;

@implementation BaseTableViewController
#pragma mark 加载通用的视图
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    [self.view addSubview:self.tableView];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.searchController.active=NO;
    [super viewWillDisappear:animated];
}

#pragma mark 设置导航的标题
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

#pragma mark 加载或错误提示
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
    NSLog(@"%ld",(long)([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus));
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

#pragma mark 子类必须实现的数据加载的方法
-(void)loadData{
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!self.searchController.active){
        cell.textLabel.text=[dataList[indexPath.row] valueForKey:kName];
        cell.detailTextLabel.text=[dataList[indexPath.row] valueForKey:kId];
    }
    else{
        cell.textLabel.text=[searchResult[indexPath.row] valueForKey:kName];
        cell.detailTextLabel.text=[searchResult[indexPath.row] valueForKey:kId];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.searchController.active)
        return dataList.count;
    else
        return searchResult.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

#pragma mark UISearchResultsUpdating
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

@end
