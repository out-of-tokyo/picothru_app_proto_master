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
@synthesize beaconId = _beaconId;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [WPYTokenizer setPublicKey:@"test_public_fdvbxDd9c2VCcftgP6b2o99z"];
	
	// スキャンしたデータの初期化
	self.products = [[NSMutableArray alloc] init];
	
	//iBeacon
	if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
		_beaconId = @"D87CEE67-C2C2-44D2-A847-B728CF8BAAAD";
		// CLLocationManagerの生成とデリゲートの設定
		self.locationManager = [CLLocationManager new];
		self.locationManager.delegate = self;
		
		// 生成したUUIDからNSUUIDを作成
		self.proximityUUID = [[NSUUID alloc] initWithUUIDString:_beaconId];
		
		// 観測するビーコン領域の作成
		self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"net.noumenon-th"];
		
		//以下はデフォルト値で設定されている
		self.beaconRegion.notifyOnEntry = YES;
		self.beaconRegion.notifyOnExit = YES;
		self.beaconRegion.notifyEntryStateOnDisplay = NO;
		
		// Beaconによる領域観測を開始
		[self.locationManager startMonitoringForRegion:self.beaconRegion];
		
	}
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSLog(@"ビーコン領域に入りました");
	[self sendLocalNotificationForMessage:@"ビーコン領域に入りました"];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	NSLog(@"ビーコン領域を出ました");
	[self sendLocalNotificationForMessage:@"ビーコン領域を出ました"];
	
}

//新しい領域のモニタリングを開始したことを伝える
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	[self.locationManager requestStateForRegion:region];
}

//モニタリングの結果を受けて、現在どのような状態かを知らせる
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
	switch (state) {
		case CLRegionStateInside:
			NSLog(@"ビーコン領域にいます");
			break;
		case CLRegionStateOutside:
			NSLog(@"ビーコン領域外です");
			break;
		case CLRegionStateUnknown:
			NSLog(@"どちらにいるのか良く分かりません");
			break;
		default:
			break;
	}
}

- (NSString *)getBeaconId
{
	return _beaconId;
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
	UILocalNotification *localNotification = [UILocalNotification new];
	localNotification.alertBody = message;
	localNotification.fireDate = [NSDate date];
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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
//   [self saveContext];
}

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
- (NSString *)setScanedProduct:(NSString *)name andPrice:(NSNumber *)price
{
	NSMutableDictionary * product = [NSMutableDictionary dictionary];
	product[@"name"] = name;
	product[@"price"] = price;
	product[@"number"] = @1;
	
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
	int num = [_products[scanedNumber][@"number"] integerValue];
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
	int num = [_products[scanedNumber][@"number"] integerValue];
	num++;
	_products[scanedNumber][@"number"] = [NSNumber numberWithInt:num];
		return @"Success";
}

- (NSString *)getName:(int)scanedNumber
{
	return _products[scanedNumber][@"name"];
}

- (NSNumber *)getPrice:(int)scanedNumber
{
	return _products[scanedNumber][@"price"];
}

- (NSNumber *)getNumber:(int)scanedNumber
{
	return _products[scanedNumber][@"number"];
}

- (NSString *)deleteProduct:(int)scanedNumber
{
	[_products removeObjectAtIndex:scanedNumber];
	return @"Success";
}

@end
