//
//  PurchaseViewController.h
//  picothru
//
//  Created by 谷村元気 on 2014/09/20.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CardViewController.h"
@class ViewController;
@interface PurchaseViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) ViewController *ViewController;
@property (weak, nonatomic) CardViewController *CardViewController;
@end
