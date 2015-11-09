//
//  CountyViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/8.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "CountyViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "WeatherViewController.h"
static NSString *const kCityId=@"cityId";
static NSString *const kCountyId=@"countyId";
static NSString *const kCountyName=@"countyName";
static NSString *const kCountyEntity=@"County";

@interface CountyViewController(){
    NSMutableArray *countyList;
}

@end
@implementation CountyViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self.navigationController.view viewWithTag:100]removeFromSuperview];
    [self setTitle:@"区/县"];
}
-(void)loadData{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    NSEntityDescription *description=[NSEntityDescription entityForName:kCountyEntity inManagedObjectContext:context];
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc]initWithKey:kCountyId ascending:YES];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%@=%@",kCityId,self.cityId];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    [request setPredicate:predicate];
    
    NSArray *fetchResult=[context executeFetchRequest:request error:nil];
    if(fetchResult.count>0){
        countyList=[[NSMutableArray alloc]init];
        for(NSManagedObject *item in fetchResult){
            NSDictionary *dic=@{kCountyId:[item valueForKey:kCountyId],
                                kCountyName:[item valueForKey:kCountyName]};
            [countyList addObject:dic];
        }
        return;
    }
    [self getCountyDataFromServer];
}
-(void)getCountyDataFromServer{
    [self showLoading];
    countyList=[[NSMutableArray alloc]init];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFHTTPResponseSerializer alloc]init];
    
    NSString *request=[@"http://www.weather.com.cn/data/list3/city**.xml?level=3" stringByReplacingOccurrencesOfString:@"**" withString:self.cityId];
    
    [manager GET:request parameters:nil success:
     ^(AFHTTPRequestOperation *operation,id response){
         NSString *countyData=[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
         [self saveCountyData:countyData];
     }failure:
     ^(AFHTTPRequestOperation *operation,NSError *error){
         NSLog(@"%@",error);
         [self hideLoading];
         [self showError];
     }];
}
-(void)saveCountyData:(NSString*)countyData{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    
    NSArray* counties=[countyData componentsSeparatedByString:@","];
    for(NSString *item in counties){
        NSArray *tuple=[item componentsSeparatedByString:@"|"];
        if(tuple.count>=2){
            NSDictionary *dic=@{kCountyId:tuple[0],kCountyName:tuple[1]};
            [countyList addObject:dic];
            NSManagedObject *object=[NSEntityDescription insertNewObjectForEntityForName:kCountyEntity inManagedObjectContext:context];
            [object setValue:tuple[0] forKey:kCountyId];
            [object setValue:tuple[1] forKey:kCountyName];
            [object setValue:self.cityId forKey:kCityId];
        }
    }
    
    [self hideLoading];
    [appDelegate saveContext];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  countyList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text=countyList[indexPath.row][kCountyName];
    cell.detailTextLabel.text=countyList[indexPath.row][kCountyId];
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    WeatherViewController*controller=(WeatherViewController*)appDelegate.deckViewController.centerController;
    controller.countyId=countyList[indexPath.row][kCountyId];
    [controller refreshView];
}
@end
