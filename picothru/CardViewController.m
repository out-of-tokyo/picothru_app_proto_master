//
//  CardViewController.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/12.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import "CardViewController.h"
#import "PurchaseViewController.h"
#import "Webpay.h"
#import "WPYToken.h"
#import "Payment.h"
#import "WPYPaymentViewController.h"
@interface CardViewController ()

@end

@implementation CardViewController
WPYCreditCard *card;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // WPYCardFormViewを作成し、自らをデリゲートに設定します
    card = [[WPYCreditCard alloc] init];
    WPYCardFormView *cardForm = [[WPYCardFormView alloc] initWithFrame:CGRectMake(0, 150, 320, 300) card:card];
    cardForm.delegate = self;
    [self.view addSubview: cardForm];
    
    _button = [[UIButton alloc] init];
    _button.frame = CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80);
    _button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _button.backgroundColor = [UIColor greenColor];
    [ _button setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _button setTitle:@"このカードを登録する" forState:UIControlStateNormal ];
    _button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button addTarget:self action:@selector(donecard:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    self.button.enabled = NO;
    UINavigationBar *nav = [[UINavigationBar alloc] init];
    nav.frame = CGRectMake(0, 0, 320, 64);
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"決済情報入力"];
    [nav setItems:@[item]];
    [self.view addSubview:nav];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)validFormWithCard:(WPYCreditCard *)creditCard
{
    // フォームに入力されたカード情報がバリデーションを通ると呼ばれます
    self.button.enabled = YES;
}
-(void)donecard:(UIButton *)button{
    NSMutableDictionary *card_info = [NSMutableDictionary dictionary];
    card_info[@"card_name"] = card.name;
    card_info[@"card_number"] = card.number;
    card_info[@"card_cvc"] = card.cvc;
    card_info[@"card_month"] = @(card.expiryMonth);
    card_info[@"card_year"] = @(card.expiryYear);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:card_info forKey:@"card_info"];
    PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pvc"];
    [self presentViewController:purchaseViewController animated:YES completion:nil];

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
