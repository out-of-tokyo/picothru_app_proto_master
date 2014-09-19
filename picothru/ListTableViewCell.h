//
//  ListTableViewCell.h
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/11.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *prodactname;
@property (weak, nonatomic) IBOutlet UILabel *prodactprice;
@property (weak, nonatomic) IBOutlet UILabel *prodactcount;

@end
