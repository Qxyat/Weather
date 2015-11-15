//
//  CityProvinceViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/8.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "CityViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "CountyViewController.h"

static NSString *const kProvinceId=@"provinceId";
static NSString *const kCityId=@"cityId";
static NSString *const kCityName=@"cityName";
static NSString *const kCityEntity=@"City";

NSString *kId=@"cityId";
NSString *kName=@"cityName";

@implementation CityViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    kId=@"cityId";
    kName=@"cityName";
    [self setTitle:@"市"];
    
    [self loadData];
}

#pragma mark 加载和保存需要的数据
-(void)loadData{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    NSEntityDescription *description=[NSEntityDescription entityForName:kCityEntity inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:kCityId ascending:YES];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%@=%@",kProvinceId,self.provinceId];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObject: sortDescriptor]];
    [request setPredicate:predicate];
    
    NSArray *fetchResult=[context executeFetchRequest:request error:nil];
    
    if(fetchResult.count>0){
        dataList=[[NSMutableArray alloc] init];
        for(NSManagedObject *item in fetchResult){
            NSDictionary *dic=@{kCityId:[item valueForKey:kCityId],
                                kCityName:[item valueForKey:kCityName]};
            [dataList addObject:dic];
        }
        return;
    }
    [self getCityDataFromServer];
}
-(void)getCityDataFromServer{
    [self showLoading];
    dataList=[[NSMutableArray alloc]init];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFHTTPResponseSerializer alloc]init];
    NSString *request=[@"http://www.weather.com.cn/data/list3/city**.xml?level=2" stringByReplacingOccurrencesOfString:@"**" withString:self.provinceId];
    [manager GET:request parameters:nil success:
     ^(AFHTTPRequestOperation *option,id response){
         NSString *cityData=[[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
         [self saveCityData:cityData];
     }failure:
     ^(AFHTTPRequestOperation *operation,NSError *error){
         NSLog(@"%@",error);
         [self hideLoading];
         [self showError];
     }
     ];
}
-(void)saveCityData:(NSString *)cityData{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    
    NSArray *cities=[cityData componentsSeparatedByString:@","];
    
    for(NSString *item in cities){
        NSArray *tuple=[item componentsSeparatedByString:@"|"];
        if(tuple.count>=2){
            NSDictionary *dic=@{kCityId:tuple[0],kCityName:tuple[1]};
            [dataList addObject:dic];
            NSManagedObject *object=[NSEntityDescription insertNewObjectForEntityForName:kCityEntity inManagedObjectContext:context];
            [object setValue:tuple[0] forKey:kCityId];
            [object setValue:tuple[1] forKey:kCityName];
            [object setValue:self.provinceId forKey:kProvinceId];
        }
    }
    [self hideLoading];
    [appDelegate saveContext];
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        [self showLocatedCityWeather];
    }
    else{
        CountyViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"county"];
        if(!self.searchController.active)
            controller.cityId=dataList[indexPath.row][kId];
        else
            controller.cityId=searchResult[indexPath.row][kId];
        [self.navigationController pushViewController:controller animated:YES];
    }
}
@end
