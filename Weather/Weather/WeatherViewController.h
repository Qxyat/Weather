//
//  WeatherViewController.h
//  Weather
//
//  Created by 邱鑫玥 on 15/11/8.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController
-(void)refreshView;

@property int refreashWay;
@property (strong,nonatomic)NSString *cityName;
@property (strong,nonatomic)NSString *countyId;

@end
