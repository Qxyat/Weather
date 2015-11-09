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
@interface CityViewController()
{
    NSMutableArray* cityList;
}

@end

@implementation CityViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self.navigationController.view viewWithTag:100]removeFromSuperview];
    [self setTitle:@"市"];
}
-(void)loadData{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
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
        cityList=[[NSMutableArray alloc] init];
        for(NSManagedObject *item in fetchResult){
            NSDictionary *dic=@{kCityId:[item valueForKey:kCityId],
                                kCityName:[item valueForKey:kCityName]};
            [cityList addObject:dic];
        }
        return;
    }
    [self getCityDataFromServer];
}
-(void)getCityDataFromServer{
    [self showLoading];
    cityList=[[NSMutableArray alloc]init];
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
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context=appDelegate.managedObjectContext;
    
    NSArray *cities=[cityData componentsSeparatedByString:@","];
    
    for(NSString *item in cities){
        NSArray *tuple=[item componentsSeparatedByString:@"|"];
        if(tuple.count>=2){
            NSDictionary *dic=@{kCityId:tuple[0],kCityName:tuple[1]};
            [cityList addObject:dic];
            NSManagedObject *object=[NSEntityDescription insertNewObjectForEntityForName:kCityEntity inManagedObjectContext:context];
            [object setValue:tuple[0] forKey:kCityId];
            [object setValue:tuple[1] forKey:kCityName];
            [object setValue:self.provinceId forKey:kProvinceId];
        }
    }
    [self hideLoading];
    [appDelegate saveContext];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  cityList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text=cityList[indexPath.row][kCityName];
    cell.detailTextLabel.text=cityList[indexPath.row][kCityId];
    return cell;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    CountyViewController *controller=segue.destinationViewController;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
    controller.cityId=cityList[indexPath.row][kCityId];
}
@end
