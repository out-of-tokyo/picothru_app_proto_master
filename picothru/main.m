//
//  main.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        @try{
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }@catch (NSException *exception) {
            NSLog(@"落ちた箇所:%@",  [exception callStackSymbols]);
            NSLog(@"落ちた原因:%@", exception);
        }
    }
    
    /*@autoreleasepool {
     return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
     }*/

}
