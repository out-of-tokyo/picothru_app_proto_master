//
//  NewsViewController.m
//  picothru
//
//  Created by 谷村元気 on 2014/09/28.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "NewsViewController.h"
#import "ViewController.h"
#import "PurchaseViewController.h"

@interface NewsViewController ()
{
	UIButton *_scanbutton;
	UIButton *_newsbutton;
	UIButton *_purchasebutton;

}
@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//上のナビゲーションバー
	UINavigationBar *nav = [[UINavigationBar alloc] init];
	nav.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
	UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"新聞画面"];
	nav.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	[nav setItems:@[item]];
	[UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.000];
	[self.view addSubview:nav];
	
	//スキャン画面へ移るボタン
	UIImage *img_scan = [UIImage imageNamed:@"scan-menu.png"];
	_scanbutton = [[UIButton alloc] init];
	_scanbutton.frame = CGRectMake(0, self.view.bounds.size.height - 60 , 107, 60);
	_scanbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _scanbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_scanbutton setBackgroundImage:img_scan forState:UIControlStateNormal];
	[_scanbutton addTarget:self action:@selector(gotoscan:) forControlEvents:UIControlEventTouchUpInside];
	
	NSLog(@"self.view.bounds.size.width: %f",self.view.bounds.size.width);
	NSLog(@"self.view.bounds.size.height: %f",self.view.bounds.size.height);
	
	//新聞画面へ移るボタン(動作なし)
	UIImage *img_news = [UIImage imageNamed:@"news-menu.png"];
	_newsbutton = [[UIButton alloc] init];
	_newsbutton.frame = CGRectMake(107, self.view.bounds.size.height - 60 , 106, 60);
	_newsbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.392 blue:0.0 alpha:1.0];
	[ _newsbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_newsbutton setBackgroundImage:img_news forState:UIControlStateNormal];
	
	//一覧画面へ移るボタン
	UIImage *img_purchase = [UIImage imageNamed:@"purchase-menu.png"];
	_purchasebutton = [[UIButton alloc] init];
	_purchasebutton.frame = CGRectMake(213, self.view.bounds.size.height - 60 , 107, 60);
	_purchasebutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _purchasebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_purchasebutton setBackgroundImage:img_purchase forState:UIControlStateNormal];
	[_purchasebutton addTarget:self action:@selector(gotoPurchase:) forControlEvents:UIControlEventTouchUpInside];
	
	NSArray *buttons =  @[_scanbutton, _newsbutton, _purchasebutton];
	for (UIButton *button in buttons) {
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		button.titleLabel.adjustsFontSizeToFitWidth = YES;
		[self.view addSubview:button];
	}
}

-(void)gotoscan:(UIButton*)button{
	ViewController *ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
	[self presentViewController:ViewController animated:YES completion:nil];
}

-(void)gotoPurchase:(UIButton*)button{
	PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pvc"];
	[self presentViewController:purchaseViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
