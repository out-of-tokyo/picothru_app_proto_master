//
//  ConViewController.m
//  picothru
//
//  Created by 谷村元気 on 2014/09/20.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "ConViewController.h"
#import "ViewController.h"
#import "Entity.h"
#import "Payment.h"
#import "ListTableViewCell.h"
#import "CardViewController.h"
#import "Webpay.h"
#import "AppDelegate.h"

@interface ConViewController ()

@end

@implementation ConViewController
NSInteger labelindex;
NSInteger total;
NSArray *cardinfo;
NSString *tokenid;
NSMutableArray *codes;
NSNumber *beacon_id;
NSMutableArray *purchase;
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
	
	if ([appDelegate getCount] !=0) {
		NSLog(@"debug product: %@",[appDelegate getScanedProduct:0]);
		NSLog(@"[appDelegate getName:0]%@",[appDelegate getName:0]);
		NSLog(@"[appDelegate getPrice:0]%@",[appDelegate getPrice:0]);
		NSLog(@"[appDelegate getNumber:0]%@",[appDelegate getNumber:0]);

	
	}
	
	//変数初期化処理
//	codearray =[[NSMutableArray array]init];
//    list = [[NSArray alloc]init];
//    labelindex = -1;

	
	// テーブル定義、位置指定
	UITableView *tableView = [[UITableView alloc]initWithFrame: CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 264) style:UITableViewStylePlain];
	[self.view addSubview:tableView];


//	names = [NSMutableArray array];
//	for(int i=0;i<20;i++){
//		[names addObject:@"ごりらの鼻くそ"];
//	}
//	prices = [NSMutableArray array];
//	for(int i=0;i<20;i++){
//		[prices addObject:[NSNumber numberWithInt:[@"100" intValue]]];
//		
//	}
//	numbers = [NSMutableArray array];
//	for(int i=0;i<20;i++){
//		[numbers addObject:[NSNumber numberWithInt:[@"1" intValue]]];
//	}
	
	
	
	
	//上のナビゲーションバー
    UINavigationBar *nav = [[UINavigationBar alloc] init];
    nav.frame = CGRectMake(0, 0, 320, 64);
    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"会計確認"];
    [nav setItems:@[item]];
    [self.view addSubview:nav];
    
    
    // スキャン画面へ遷移ボタン
    UIButton *back = [[UIButton alloc] init];
    back.frame = CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80);
    back.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    back.backgroundColor = [UIColor orangeColor];
    [ back setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ back setTitle:@"スキャン画面に戻る" forState:UIControlStateNormal ];
    back.titleLabel.adjustsFontSizeToFitWidth = YES;
    [back addTarget:self action:@selector(gotoscan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
	// 会計完了ボタン
    UIButton *done = [[UIButton alloc] init];
    done.frame = CGRectMake(0, self.view.bounds.size.height - 160, self.view.bounds.size.width, 80);
    done.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    done.backgroundColor = [UIColor greenColor];
    [ done setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ done setTitle:@"会計を完了する" forState:UIControlStateNormal ];
    done.titleLabel.adjustsFontSizeToFitWidth = YES;
    [done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:done];
	
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil]forCellReuseIdentifier:@"cell"];
	

}

-(void)viewDidAppear:(BOOL)animated
{
    total = 0;
    NSLog(@"prices count = %d",[appDelegate getCount]);
    for(int i = 0;i < [appDelegate getCount]; i++) {
		NSInteger tmp = [[appDelegate getPrice:i] integerValue];
		tmp *= [[appDelegate getNumber:i]integerValue];
        NSLog(@"tmp = %ld (i = %ld)",(long)tmp,(long)i);
        NSLog(@"%ld + %ld = %ld",(long)total,(long)tmp,(long)(total+tmp));
        total += tmp;
    }

    UILabel *goukei = [[UILabel alloc] init];
    goukei.frame = CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 40);
    goukei.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    goukei.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    goukei.textColor = [UIColor whiteColor];
    goukei.textAlignment = NSTextAlignmentCenter;
    NSString *txt = [NSString stringWithFormat:@"%ld", (long)total];
    NSLog(@"%ld",(long)total);
    NSString *totaltxt = [NSString stringWithFormat:@"合計%@円",txt];
    goukei.text = totaltxt ;
    [self.view addSubview: goukei];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	cell.prodactname.text = [appDelegate getName:(int)indexPath.row];
    cell.prodactprice.text = [appDelegate getPrice:(int)indexPath.row];
	cell.prodactcount.text = [appDelegate getNumber:(int)indexPath.row];
	
	return cell;
}

-(void)gotoscan:(UIButton*)button{
    ViewController *ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
    [self presentViewController:ViewController animated:YES completion:nil];
}

-(void)register:(UIButton*)button{
    CardViewController *CardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cvc"];
    [self presentViewController:CardViewController animated:YES completion:nil];
}

-(void)done:(UIButton*)button{
    /*id delegate = [[UIApplication sharedApplication] delegate];
     self.managedObjectContext = [delegate managedObjectContext];
     NSManagedObjectContext *moc = [self managedObjectContext];
     NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
     NSEntityDescription *d = [NSEntityDescription entityForName: @"Payment" inManagedObjectContext:_managedObjectContext];
     [fetchrequest setEntity:d];
     NSError *error = nil;
     cardinfo = [moc executeFetchRequest:fetchrequest error:&error];
     if([cardinfo valueForKeyPath:@"name"], [cardinfo valueForKeyPath:@"number"],[cardinfo valueForKeyPath:@"month"], [cardinfo valueForKeyPath:@"year"],[cardinfo valueForKeyPath:@"cvc"] ){
     ;
     }
     CardViewController *CardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cvc"];
     [self presentViewController:CardViewController animated:YES completion:nil];*/
    [self createtoken];
    [self posttoken];
}

- (void)createtoken{
    // カードモデルを作成し、必要な値を渡し ます
    WPYCreditCard *card = [[WPYCreditCard alloc] init];
    card.number = @"4242424242424242";
    card.expiryYear = 2015;
    card.expiryMonth = 12;
    card.cvc = @"123";
    card.name = @"TARO YAMADA";
    
    // カードモデルとコールバックを渡します
    [WPYTokenizer createTokenFromCard:card completionBlock:^(WPYToken *token, NSError *error){
        if (token){
            NSLog(@"token:%@", token.tokenId);
            tokenid = token.tokenId;
        }else{
            NSLog(@"error:%@", [error localizedDescription]);
        }
    }];
    
}

- (void)posttoken{
    
    //テスト用
    /*
     
     codes = [[NSMutableArray alloc]init];
	 numbers = [[NSMutableArray alloc]init];
	 beacon_id = @"4";
	 NSString *total_price = @"450";
	 tokenid = @"45mjff8pdmh";
	 [codes addObject:@"345447762"];
	 [codes addObject:@"245856512"];
	 [numbers addObject:@"2"];
	 [numbers addObject:@"1"];
	 
	 purchase = [[NSMutableArray alloc]init];
	 for(int i = 0; i < [codes count]; i++){
	 NSMutableDictionary *codestmp = [NSMutableDictionary dictionaryWithObjectsAndKeys:codes[i], @"barcode_id",numbers[i], @"amount", nil];
	 [purchase addObject:codestmp];
	 }
	 
	 */
	
    NSString *total_price = [[NSString alloc] initWithFormat:@"%ld",(long)total];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:beacon_id forKey:@"store_id"];
    [mutableDic setValue:purchase forKey:@"purchase"];
    [mutableDic setValue:total_price forKey:@"total_price"];
    [mutableDic setValue:tokenid forKey:@"token"];
    NSError *error = nil;
    NSLog(@"%@",mutableDic);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDic options:0 error:&error];
    NSString *url = @"http://54.64.69.224/api/v0/purchase";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(response){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
        BOOL loginResult = [array valueForKey:@"status"];
        if (loginResult){
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Picoした" message:@"完了しました" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
            [Scanitems MR_truncateAll];
            ViewController *ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
            [self presentViewController:ViewController animated:YES completion:nil];
        }else{
            [self errormessage];
        }
    }else{
        [self errormessage];
    }
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
