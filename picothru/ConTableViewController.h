//
//  ConTableViewController.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/11.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CardViewController.h"
@class ViewController;
@interface ConTableViewController : UITableViewController
@property (weak, nonatomic) ViewController *ViewController;
@property (weak, nonatomic) CardViewController *CardViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
