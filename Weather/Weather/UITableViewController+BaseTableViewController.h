//
//  UITableViewController+BaseTableViewController.h
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (BaseTableViewController)
-(void)showLoading;
-(void)hideLoading;
-(void)showError;
-(void)hideError;
@end
