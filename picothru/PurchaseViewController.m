//
//  PurchaseViewController.m
//  picothru
//
//  Created by 谷村元気 on 2014/09/20.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "PurchaseViewController.h"
#import "ViewController.h"
#import "QRcodeViewController.h"
#import "ListTableViewCell.h"
#import "CardViewController.h"
#import "Webpay.h"
#import "AppDelegate.h"
#import "NewsViewController.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController
NSInteger labelindex;
NSInteger total;
NSArray *cardinfo;
NSString *tokenid;
NSMutableArray *codes;
NSNumber *beacon_id;
NSMutableArray *purchase;
NSDictionary *card_info;
NSUserDefaults *defaults;
UIButton *_scanbutton;
UIButton *_newsbutton;
UIButton *_purchasebutton;
AppDelegate *appDelegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//デリゲート生成
	appDelegate = [[UIApplication sharedApplication] delegate];
		
	// テーブル定義、位置指定
	UITableView *tableView = [[UITableView alloc]initWithFrame: CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 264) style:UITableViewStylePlain];
	tableView.tableFooterView = [[UIView alloc] init];
	[self.view addSubview:tableView];
	
	//上のナビゲーションバー
	UINavigationBar *nav = [[UINavigationBar alloc] init];
	nav.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
	UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"購入確認"];
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
	_newsbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _newsbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_newsbutton setBackgroundImage:img_news forState:UIControlStateNormal];
	[_newsbutton addTarget:self action:@selector(gotoNews:) forControlEvents:UIControlEventTouchUpInside];

	
	//一覧画面へ移るボタン(動作なし)
	UIImage *img_purchase = [UIImage imageNamed:@"purchase-menu.png"];
	_purchasebutton = [[UIButton alloc] init];
	_purchasebutton.frame = CGRectMake(213, self.view.bounds.size.height - 60 , 107, 60);
	_purchasebutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.392 blue:0.0 alpha:1.0];
	[ _purchasebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_purchasebutton setBackgroundImage:img_purchase forState:UIControlStateNormal];
    
	// 会計完了ボタン
    UIButton *done = [[UIButton alloc] init];
    done.frame = CGRectMake(20, self.view.bounds.size.height - 140, self.view.bounds.size.width - 40, 60);
    done.backgroundColor = [UIColor orangeColor];
    [ done setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ done setTitle:@"決済" forState:UIControlStateNormal ];
    [done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];

	NSArray *buttons =  @[_scanbutton, _newsbutton, _purchasebutton, done];
	for (UIButton *button in buttons) {
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		button.titleLabel.adjustsFontSizeToFitWidth = YES;
		[self.view addSubview:button];
	}
	
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil]forCellReuseIdentifier:@"cell"];

    defaults = [NSUserDefaults standardUserDefaults];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appDelegate getCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"cell";
	ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    int i = (int)indexPath.row;
	cell.prodactname.text = [appDelegate getName:i];
    cell.prodactprice.text = [appDelegate.products[i][@"price"] stringValue];
	cell.prodactcount.text = [appDelegate.products[i][@"amount"] stringValue];
	return cell;
}

-(void)gotoscan:(UIButton*)button{
    ViewController *ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
    [self presentViewController:ViewController animated:YES completion:nil];
}

-(void)gotoNews:(UIButton*)button{
	NewsViewController *newsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"nw"];
	[self presentViewController:newsViewController animated:YES completion:nil];
}

-(void)gotoPurchase:(UIButton*)button{
	PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"nw"];
	[self presentViewController:purchaseViewController animated:YES completion:nil];
}

-(void)done:(UIButton*)button{
    card_info = [defaults dictionaryForKey:@"card_info"];
    if(card_info == nil){
        CardViewController *CardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cvc"];
    [self presentViewController:CardViewController animated:YES completion:nil];
    }else{
        [self createtoken];
    }
}

- (void)createtoken{
    // カードモデルを作成し、必要な値を渡します
    WPYCreditCard *card = [[WPYCreditCard alloc] init];
    card.number = card_info[@"card_number"];
    card.expiryYear =[card_info[@"card_year"] integerValue];
    card.expiryMonth = [card_info[@"card_month"] integerValue];
    card.cvc = card_info[@"card_cvc"];
    card.name =card_info[@"card_name"];
    
    // カードモデルとコールバックを渡します
    [WPYTokenizer createTokenFromCard:card completionBlock:^(WPYToken *token, NSError *error){
        if (token){
            NSLog(@"token:%@", token.tokenId);
            tokenid = token.tokenId;
            QRcodeViewController *qrcodeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"qrvc"];
            qrcodeViewController.purchaseDictionary = [self createPurchaseDictionary];;
            [self presentViewController:qrcodeViewController animated:YES completion:nil];
        }else{
            NSLog(@"error:%@", [error localizedDescription]);
        }
    }];
}

- (NSDictionary *) createPurchaseDictionary{
    NSNumber *total_price = [NSNumber numberWithInteger:total];
    for (NSMutableDictionary *product in appDelegate.products) {
        [product removeObjectForKey:@"name"];
        [product removeObjectForKey:@"price"];
    }
    NSDictionary *purchaseDictionary = @{@"beacon_id":@"D87CEE67-C2C2-44D2-A847-B728CF8BAAAD",
                                         @"total_price":total_price,
                                         @"products":appDelegate.products,
                                         @"token":tokenid};
    return purchaseDictionary;
}

-(void)errormessage{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"PicoNothru" message:@"エラー" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [alert show];
}

/*
  Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
  Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
  Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
  Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
  Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
  Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
  Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
  Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
  In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
  Get the new view controller using [segue destinationViewController].
  Pass the selected object to the new view controller.
 }
 */

@end
