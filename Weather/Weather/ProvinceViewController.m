//
//  ProvinceViewController.m
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import "ProvinceViewController.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "CityViewController.h"
static NSString *const kProvinceName=@"provinceName";
static NSString *const kProvinceId=@"provinceId";
static NSString *const kProvinceEntity=@"Province";



@implementation ProvinceViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    kId=@"provinceId";
    kName=@"provinceName";
    [self setTitle:@"省"];
    
    [self loadData];
}

#pragma mark 加载和保存需要的数据
-(void)loadData{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *description=[NSEntityDescription entityForName:kProvinceEntity inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:kProvinceId ascending:YES];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray *fetchResult=[context executeFetchRequest:request error:nil];
    if(fetchResult.count>0){
        dataList=[[NSMutableArray alloc]init];
        for(NSManagedObject *item in fetchResult){
            NSDictionary *dic=@{kProvinceId:[item valueForKey:kProvinceId],
                                kProvinceName:[item valueForKey:kProvinceName]};
            [dataList addObject:dic];
        }
        return;
    }
    [self getProvinceDataFromServer];
}
-(void) getProvinceDataFromServer{
    [self showLoading];
    dataList=[[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[[AFHTTPResponseSerializer alloc]init];
    [manager GET:@"http://www.weather.com.cn/data/list3/city.xml?level=1"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation,id response){
             NSString *provinceData=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
             [self saveProvinceData:provinceData];
         }
         failure:^(AFHTTPRequestOperation *operation,NSError *error){
             NSLog(@"%@",error);
             [self hideLoading];
             [self showError];
         }
     ];
}
-(void) saveProvinceData:(NSString *)provinceData{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    
    NSArray *provinces=[provinceData componentsSeparatedByString:@","];
    
    for(NSString *item in provinces){
        NSArray *tuple=[item componentsSeparatedByString:@"|"];
        if(tuple.count>=2){
            NSDictionary *dic=@{kProvinceId:tuple[0],kProvinceName:tuple[1]};
            [dataList addObject:dic];
            NSManagedObject* object=[NSEntityDescription insertNewObjectForEntityForName:kProvinceEntity inManagedObjectContext:context];
            [object setValue:tuple[0] forKey:kProvinceId];
            [object setValue:tuple[1] forKey:kProvinceName];
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
        CityViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"city"];
        if(!self.searchController.active)
            controller.provinceId=dataList[indexPath.row][kId];
        else
            controller.provinceId=searchResult[indexPath.row][kId];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
