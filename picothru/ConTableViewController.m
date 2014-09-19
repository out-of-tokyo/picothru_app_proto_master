//
//  ConTableViewController.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/11.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "ConTableViewController.h"
#import "ViewController.h"
#import "Entity.h"
#import "Payment.h"
#import "ListTableViewCell.h"
#import "CardViewController.h"
#import "Webpay.h"

@interface ConTableViewController ()

@end

@implementation ConTableViewController

NSArray *list;
NSArray *names;
NSArray *prices;
NSArray *numbers;
NSInteger total;
NSArray *cardinfo;
NSString *tokenid;
NSMutableArray *codes;
NSNumber *store_id;
int i;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //coredataの読み込み
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *d = [NSEntityDescription entityForName: @"Scanitems" inManagedObjectContext:_managedObjectContext];
    [fetchrequest setEntity:d];
    NSError *error = nil;
    list = [moc executeFetchRequest:fetchrequest error:&error];
    names = [list valueForKeyPath:@"names"];
    prices = [list valueForKeyPath:@"prices"];
    numbers = [list valueForKeyPath:@"number"];
    codes = [NSKeyedUnarchiver unarchiveObjectWithData:[list valueForKeyPath:@"scanedcodes"]];
    //    names = [NSArray arrayWithObjects:@"ゴリラのはなくそ", @"ぷりん", @"生しらす", nil];
    //    prices = [NSArray arrayWithObjects:@"100", @"150", @"50", nil];
    //	NSLog(@"%@",list);
	
    //	NSLog(@"###################names: %@#####################",[list valueForKeyPath:@"names"]);
    //	NSLog(@"###################prices: %@#####################",[list valueForKeyPath:@"prices"]);
    
    //	NSArray * temp_n = [list valueForKeyPath:@"names"];
    //	NSString * temp_p = [[list valueForKeyPath:@"prices"] objectAtIndex:0];
    //	NSLog(@"%@, %@",temp_n,temp_p);
    
    //    names = [NSArray arrayWithObjects:temp_n, nil];
    //    prices = [NSArray arrayWithObjects:temp_p, nil];
    
    //	NSLog(@"name: %@, prices: %@",names,prices);
	
    UINavigationBar *nav = [[UINavigationBar alloc] init];
    nav.frame = CGRectMake(0, -64, 320, 64);
    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"会計確認"];
    [nav setItems:@[item]];
    [self.view addSubview:nav];
    
    
    
    UIButton *back = [[UIButton alloc] init];
    back.frame = CGRectMake(0, self.view.bounds.size.height - 144, self.view.bounds.size.width, 80);
    back.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    back.backgroundColor = [UIColor orangeColor];
    [ back setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ back setTitle:@"スキャン画面に戻る" forState:UIControlStateNormal ];
    back.titleLabel.adjustsFontSizeToFitWidth = YES;
    [back addTarget:self action:@selector(gotoscan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    UIButton *done = [[UIButton alloc] init];
    done.frame = CGRectMake(0, self.view.bounds.size.height - 224, self.view.bounds.size.width, 80);
    done.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    done.backgroundColor = [UIColor greenColor];
    [ done setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ done setTitle:@"会計を完了する" forState:UIControlStateNormal ];
    done.titleLabel.adjustsFontSizeToFitWidth = YES;
    [done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:done];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top += 64;
    self.tableView.contentInset = insets;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	[self.tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil]forCellReuseIdentifier:@"cell"];
}

-(void)viewDidAppear:(BOOL)animated
{
	total = 0;
	NSLog(@"prices count = %ld",(long)[prices count]);
    for(i = 0;i < [names count]; i++) {
        NSInteger tmp = [prices[i] integerValue];
		NSLog(@"tmp = %ld (i = %ld)",(long)tmp,(long)i);
		NSLog(@"%ld + %ld = %ld",(long)total,(long)tmp,(long)(total+tmp));
        total += tmp;
    }
    
    UILabel *goukei = [[UILabel alloc] init];
    goukei.frame = CGRectMake(0, self.view.bounds.size.height - 264, self.view.bounds.size.width, 40);
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
    return [names count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.prodactname.text = names[indexPath.row];
    NSString *pricestr = [prices[indexPath.row] stringValue];
    NSString *numberstr = [numbers[indexPath.row] stringValue];
    cell.prodactprice.text = pricestr;
    cell.prodactcount.text = numberstr;
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
    // カードモデルを作成し、必要な値を渡します
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
    NSMutableArray *purchase = [[NSMutableArray alloc]init];
    for(int i = 0; i < [codes count]; i++){
        NSMutableArray *codestmp = [[NSMutableArray alloc]init];
        NSMutableArray *counttmp = [[NSMutableArray alloc]init];
        [codestmp setValue:codes[i] forKey:@"barcode_id"];
        [counttmp setValue:numbers[i] forKey:@"amount"];
        [purchase addObject:codestmp];
        [purchase addObject:counttmp];
    }
    NSString *total_price = [[NSString alloc] initWithFormat:@"%d",total];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:store_id forKey:@"store_id"];
    [mutableDic setValue:purchase forKey:@"purchase"];
    [mutableDic setValue:total_price forKey:@"total_price"];
    [mutableDic setValue:tokenid forKey:@"token"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDic options:0 error:&error];
    NSString *url = @"http://xoxoxoxoxoxo:8080/app/login";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSData *statusdata = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *status = [NSJSONSerialization JSONObjectWithData:statusdata options:NSJSONReadingAllowFragments error:nil];
    if (status){
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Picoした" message:@"完了しました" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        [Scanitems MR_truncateAll];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context MR_saveNestedContexts];
        ViewController *ViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"vc"];
        [self presentViewController:ViewController animated:YES completion:nil];
    }else{
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"PicoNothru" message:@"エラー" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
	
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
