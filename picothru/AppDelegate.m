//
//  AppDelegate.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "AppDelegate.h"
#import "Webpay.h"

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize products = _products;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
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
    [self saveContext];}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

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
	product[@"name"] = name;
	product[@"price"] = price;
	product[@"number"] = @"1";
	
	NSLog(@"NSMutableDictionary: %@",product);

	[_products addObject:product];
	NSLog(@"_products: %@",_products);
	return @"Success";
}

// スキャンしたアイテムを出力
- (NSDictionary *)getScanedProduct:(int)scanedNumber
{
	NSLog(@"products: %@",_products);
	
	return _products[scanedNumber];
}

- (NSString *)subNumber:(int)scanedNumber
{
	NSLog(@"products: %@",_products);
	NSLog(@"[_products objectAtIndex:scanedNumber]: %@",_products[scanedNumber]);
	NSString * str = _products[scanedNumber][@"number"];
	int num = str.intValue;
	NSLog(@"num: %d",num);
	//もとの数値が1より大きければ引いて値を更新する
	if(num > 1){
		num--;
		_products[scanedNumber][@"number"] = [NSString stringWithFormat:@"%d", num];
		return [NSString stringWithFormat:@"%d", num];
	}else{
		[self deleteProduct:scanedNumber];
		return @"0";
	}
}

- (NSString *)addNumber:(int)scanedNumber
{
	NSString * str = _products[scanedNumber][@"number"];
	int num = str.intValue;
	num++;
	_products[scanedNumber][@"number"] = [NSString stringWithFormat:@"%d", num];
		return [NSString stringWithFormat:@"%d", num];
}

- (NSString *)getName:(int)scanedNumber
{
	return _products[scanedNumber][@"name"];
}

- (NSString *)getPrice:(int)scanedNumber
{
	return _products[scanedNumber][@"price"];
}

- (NSString *)getNumber:(int)scanedNumber
{
	return _products[scanedNumber][@"number"];
}

- (NSString *)deleteProduct:(int)scanedNumber
{
	[_products removeObjectAtIndex:scanedNumber];
	return @"Success";
}

@end
