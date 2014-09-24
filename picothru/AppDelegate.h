//
//  AppDelegate.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *products;
//iBeacon
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) NSString *beaconId;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// スキャンしたデータをいじる関数
- (NSString *)setScanedProduct:(NSString *)name andPrice:(NSString *)price;
- (NSDictionary *)getScanedProduct:(int)scanedNumber;
- (int)getCount;
- (NSString *)subNumber:(int)scanedNumber;
- (NSString *)addNumber:(int)scanedNumber;

- (NSString *)getName:(int)scanedNumber;
- (NSString *)getPrice:(int)scanedNumber;
- (NSString *)getNumber:(int)scanedNumber;

//iBeacon
- (NSString *)getBeaconId;

@end
