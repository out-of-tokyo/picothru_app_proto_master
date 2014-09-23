//
//  AppDelegate.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "AppDelegate.h"
#import "Webpay.h"
#import "Entity.h"

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize products = _products;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStack];
	[Scanitems MR_truncateAll];
//	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//	[context MR_saveNestedContexts];
    [WPYTokenizer setPublicKey:@"test_public_fdvbxDd9c2VCcftgP6b2o99z"];
	
	// スキャンしたデータの初期化
	self.products = [[NSMutableArray alloc] init];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
    [MagicalRecord cleanUp];
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"picothru" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"picothru.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//　スキャンしたアイテムの総数を返す
- (int)getCount
{
	return (int)[_products count];
}

//　スキャンしたアイテムを格納
- (NSString *)setScanedProduct:(NSString *)name andPrice:(NSString *)price
{
	NSMutableDictionary * product = [NSMutableDictionary dictionary];
	[product setObject:name forKey:@"name"];
	[product setObject:price forKey:@"price"];
	[product setObject:@"1" forKey:@"number"];
	
	NSLog(@"NSMutableDictionary: %@",product);
	

	[_products addObject:product];
	NSLog(@"_products: %@",_products);
	return @"Success";
}

// スキャンしたアイテムを出力
- (NSDictionary *)getScanedProduct:(int)scanedNumber
{
	NSLog(@"products: %@",_products);
	
	return [_products objectAtIndex:scanedNumber];
}

- (NSString *)subNumber:(int)scanedNumber
{
	NSLog(@"products: %@",_products);
	NSLog(@"[_products objectAtIndex:scanedNumber]: %@",[_products objectAtIndex:scanedNumber]);
	NSString * str = [_products objectAtIndex:scanedNumber][@"number"];
	int num = str.intValue;
	NSLog(@"num: %d",num);
	//もとの数値が1より大きければ引いて値を更新する
	if(num > 1){
		num--;
		[_products objectAtIndex:scanedNumber][@"number"] = [NSString stringWithFormat:@"%d", num];
		return [NSString stringWithFormat:@"%d", num];
	}else{
		[self deleteProduct:scanedNumber];
		return @"0";
	}
}

- (NSString *)addNumber:(int)scanedNumber
{
	NSString * str = [_products objectAtIndex:scanedNumber][@"number"];
	int num = str.intValue;
	num++;
	[_products objectAtIndex:scanedNumber][@"number"] = [NSString stringWithFormat:@"%d", num];
		return [NSString stringWithFormat:@"%d", num];
}

- (NSString *)getName:(int)scanedNumber
{
	return [_products objectAtIndex:scanedNumber][@"name"];
}

- (NSString *)getPrice:(int)scanedNumber
{
	return [_products objectAtIndex:scanedNumber][@"price"];
}

- (NSString *)getNumber:(int)scanedNumber
{
	return [_products objectAtIndex:scanedNumber][@"number"];
}

- (NSString *)deleteProduct:(int)scanedNumber
{
	[_products removeObjectAtIndex:scanedNumber];
	return @"Success";
}

@end
