//
//  Payment.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/12.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Payment : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * cvc;
@property (nonatomic, retain) NSString * name;

@end
