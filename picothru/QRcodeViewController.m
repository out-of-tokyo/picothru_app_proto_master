//
//  QRcodeViewController.m
//  picothru
//
//  Created by dch on 9/25/14.
//  Copyright (c) 2014 Masaru. All rights reserved.
//

#import "QRcodeViewController.h"
#import "ZXingObjC.h"
#import "AppDelegate.h"
#import "AESCrypt.h"
#import "ViewController.h"
#import "PurchaseViewController.h"
#import "NewsViewController.h"

@interface QRcodeViewController ()
{
	NSInteger total;
	UIButton *_scanbutton;
	UIButton *_newsbutton;
	UIButton *_purchasebutton;
	UIButton *_cancelbutton;
	AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;

@end

@implementation QRcodeViewController
@synthesize purchaseDictionary;
AppDelegate *appDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];

    NSData *data=[NSJSONSerialization dataWithJSONObject:purchaseDictionary options:2 error:nil];
    NSString *purchaseString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *encryptedPurchaseString = [AESCrypt encrypt:purchaseString password:@"0123456789ABCDEF"];
    UIImage *qrcode = [self createQrCode:encryptedPurchaseString];
	
	//上のナビゲーションバー
	UINavigationBar *nav = [[UINavigationBar alloc] init];
	nav.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
	UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"QRコード"];
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
	[_scanbutton addTarget:self action:@selector(gotoScan:) forControlEvents:UIControlEventTouchUpInside];
	
	//新聞画面へ移るボタン(動作なし)
	UIImage *img_news = [UIImage imageNamed:@"news-menu.png"];
	_newsbutton = [[UIButton alloc] init];
	_newsbutton.frame = CGRectMake(107, self.view.bounds.size.height - 60 , 106, 60);
	_newsbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _newsbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_newsbutton setBackgroundImage:img_news forState:UIControlStateNormal];
	[_newsbutton addTarget:self action:@selector(gotoNews:) forControlEvents:UIControlEventTouchUpInside];
	
	//一覧画面へ移るボタン
	UIImage *img_purchase = [UIImage imageNamed:@"purchase-menu.png"];
	_purchasebutton = [[UIButton alloc] init];
	_purchasebutton.frame = CGRectMake(213, self.view.bounds.size.height - 60 , 107, 60);
	_purchasebutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _purchasebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_purchasebutton setBackgroundImage:img_purchase forState:UIControlStateNormal];
	[_purchasebutton addTarget:self action:@selector(gotoPurchase:) forControlEvents:UIControlEventTouchUpInside];

	// 買い物キャンセルボタン(スキャン画面へ戻る)
	_cancelbutton = [[UIButton alloc] init];
	_cancelbutton.frame = CGRectMake(20, self.view.bounds.size.height - 140, self.view.bounds.size.width - 40, 60);
	_cancelbutton.backgroundColor = [UIColor orangeColor];
	[ _cancelbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[ _cancelbutton setTitle:@"買い物キャンセル" forState:UIControlStateNormal ];
	[_cancelbutton addTarget:self action:@selector(gotoScan:) forControlEvents:UIControlEventTouchUpInside];

	NSArray *buttons =  @[_scanbutton, _newsbutton, _purchasebutton, _cancelbutton];
	for (UIButton *button in buttons) {
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		button.titleLabel.adjustsFontSizeToFitWidth = YES;
		[self.view addSubview:button];
	}

    self.qrcodeImageView.image = qrcode;
    [self.view addSubview:self.qrcodeImageView];
}

-(void)viewDidAppear:(BOOL)animated
{
	total = 0;
	NSLog(@"prices count = %d",[appDelegate getCount]);
	for(NSDictionary *product in appDelegate.products) {
		NSInteger tmp = [product[@"price"] intValue];
		tmp *= [product[@"amount"] intValue];
		total += tmp;
	}
	
	UILabel *total_label = [[UILabel alloc] init];
	total_label.frame = CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 40);
	total_label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	total_label.backgroundColor = [UIColor colorWithRed:0.69 green:0.769 blue:0.871 alpha:1.0];
	total_label.textColor = [UIColor blackColor];
	total_label.textAlignment = NSTextAlignmentCenter;
	NSString *txt = [NSString stringWithFormat:@"%ld", (long)total];
	NSString *totaltxt = [NSString stringWithFormat:@"合計金額 ¥%@(税込)",txt];
	total_label.text = totaltxt ;
	[self.view addSubview: total_label];
}

- (UIImage *) createQrCode:(NSString *)qrcodeTxt
{
    if (qrcodeTxt == nil || [qrcodeTxt isEqualToString:@""]) {
        self.qrcodeImageView.image = nil;
        return nil;
    }

    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    CGSize imageSize = self.qrcodeImageView.frame.size;
    ZXBitMatrix *result = [writer encode:qrcodeTxt
                                  format:kBarcodeFormatQRCode
                                   width:imageSize.width
                                  height:imageSize.height
                                   error:nil];
    if (result == nil) {
        self.qrcodeImageView.image = nil;
        return nil;
    }

    CGImageRef qrImageRef = [ZXImage imageWithMatrix:result].cgimage;
    return [UIImage imageWithCGImage:qrImageRef];
}

//画面遷移ボタン
-(void)gotoScan:(UIButton *)button{
	ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
	[self presentViewController:viewController animated:YES completion:nil];
}

-(void)gotoPurchase:(UIButton *)button{
	PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pvc"];
	[self presentViewController:purchaseViewController animated:YES completion:nil];
}

-(void)gotoNews:(UIButton*)button{
	NewsViewController *newsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"nw"];
	[self presentViewController:newsViewController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
