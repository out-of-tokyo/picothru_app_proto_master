//
//  Entity.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/20.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Scanitems : NSManagedObject

@property (nonatomic, retain) NSData * names;
@property (nonatomic, retain) NSData * counts;
@property (nonatomic, retain) NSData * prices;
@property (nonatomic, retain) NSData * prodacts;
@property (nonatomic, retain) NSData * codes;

@end
