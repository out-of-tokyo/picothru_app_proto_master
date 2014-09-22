//
//  AppDelegate.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *products;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// スキャンしたデータをいじる関数
- (NSString *)setScanedProduct:(NSString *)name andPrice:(NSString *)price;
- (NSDictionary *)getScanedProduct:(int)scanedNumber;
- (int)getCount;
- (NSString *)subNumber:(int)scanedNumber;
- (NSString *)addNumber:(int)scanedNumber;

@end
