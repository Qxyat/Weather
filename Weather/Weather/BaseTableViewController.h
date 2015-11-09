//
//  UITableViewController+BaseTableViewController.h
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController:UITableViewController
-(void)showLoading;
-(void)hideLoading;
-(void)showError;
-(void)hideError;
-(void)setNavigationTitle:(NSString *)title;
@end
