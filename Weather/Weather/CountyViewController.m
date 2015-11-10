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
static NSString *const kCountyEntity=@"County";

@implementation CountyViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    kId=@"countyId";
    kName=@"countyName";
    [self setTitle:@"区/县"];
    
    [self loadData];
}

#pragma mark 加载和保存需要的数据
-(void)loadData{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    NSEntityDescription *description=[NSEntityDescription entityForName:kCountyEntity inManagedObjectContext:context];
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc]initWithKey:kId ascending:YES];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%@=%@",kCityId,self.cityId];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    [request setPredicate:predicate];
    
    NSArray *fetchResult=[context executeFetchRequest:request error:nil];
    if(fetchResult.count>0){
        dataList=[[NSMutableArray alloc]init];
        for(NSManagedObject *item in fetchResult){
            NSDictionary *dic=@{kId:[item valueForKey:kId],
                                kName:[item valueForKey:kName]};
            [dataList addObject:dic];
        }
        return;
    }
    [self getCountyDataFromServer];
}
-(void)getCountyDataFromServer{
    [self showLoading];
    dataList=[[NSMutableArray alloc]init];
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
            NSDictionary *dic=@{kId:tuple[0],kName:tuple[1]};
            [dataList addObject:dic];
            NSManagedObject *object=[NSEntityDescription insertNewObjectForEntityForName:kCountyEntity inManagedObjectContext:context];
            [object setValue:tuple[0] forKey:kId];
            [object setValue:tuple[1] forKey:kName];
            [object setValue:self.cityId forKey:kCityId];
        }
    }
    
    [self hideLoading];
    [appDelegate saveContext];
}

#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    
    WeatherViewController*controller=(WeatherViewController*)appDelegate.deckViewController.centerController;
    controller.countyId=dataList[indexPath.row][kId];
    
    [controller refreshView];
}

@end
