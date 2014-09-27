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

@interface QRcodeViewController ()
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
    
    self.qrcodeImageView.image = qrcode;
    [self.view addSubview:self.qrcodeImageView];
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
