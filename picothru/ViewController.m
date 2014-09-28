//
//  ViewController.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "PurchaseViewController.h"
#import "AppDelegate.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    UIView *_highlightView;
    UILabel *_namelabel;
    UILabel *_pricelabel;
    UILabel *_countlabel;
	UIButton *_scanbutton;
	UIButton *_newsbutton;
    UIButton *_donebutton;
    UIButton *_subbutton;
    UIButton *_addbutton;
    UIButton *_nextbutton;
    UIButton *_prebutton;
	AppDelegate *appDelegate;

	//iBeacon
	NSString *beaconId;
}
@end

@implementation ViewController
//商品履歴ラベルの位置
int labelindex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//デリゲート生成
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	beaconId = [appDelegate getBeaconId];
	
	//カメラを起動する
	[self launchCamera];

	// スキャン履歴表示ラベル
    _namelabel = [[UILabel alloc] init];
    _namelabel.frame = CGRectMake(45, self.view.bounds.size.height - 190, self.view.bounds.size.width - 90, 50);
    
    _pricelabel = [[UILabel alloc] init];
    _pricelabel.frame = CGRectMake(45, self.view.bounds.size.height - 140, self.view.bounds.size.width * 0.5 - 45, 50);
    
    _countlabel = [[UILabel alloc] init];
    _countlabel.frame = CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height - 140, self.view.bounds.size.width * 0.5 - 45, 50);
    _countlabel.text = @"0";
    
    NSArray *labels =  @[_namelabel, _pricelabel, _countlabel];
    for (UILabel *label in labels) {
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
	
	//上のナビゲーションバー
	UINavigationBar *nav = [[UINavigationBar alloc] init];
	nav.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
	UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"スキャン"];
	nav.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	[nav setItems:@[item]];
	[UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.000];
	[self.view addSubview:nav];

	//スキャン画面へ移るボタン(動作なし)
	UIImage *img_scan = [UIImage imageNamed:@"scan-menu.png"];
	_scanbutton = [[UIButton alloc] init];
	_scanbutton.frame = CGRectMake(0, self.view.bounds.size.height - 60 , 107, 60);
	_scanbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.392 blue:0.0 alpha:1.0];
	[ _scanbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_scanbutton setBackgroundImage:img_scan forState:UIControlStateNormal];

	NSLog(@"self.view.bounds.size.width: %f",self.view.bounds.size.width);
	NSLog(@"self.view.bounds.size.height: %f",self.view.bounds.size.height);

	//新聞画面へ移るボタン(動作なし)
	UIImage *img_news = [UIImage imageNamed:@"news-menu.png"];
	_newsbutton = [[UIButton alloc] init];
	_newsbutton.frame = CGRectMake(107, self.view.bounds.size.height - 60 , 106, 60);
	_newsbutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _newsbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_newsbutton setBackgroundImage:img_news forState:UIControlStateNormal];

	//一覧画面へ移るボタン
	UIImage *img_purchase = [UIImage imageNamed:@"purchase-menu.png"];
	_donebutton = [[UIButton alloc] init];
	_donebutton.frame = CGRectMake(213, self.view.bounds.size.height - 60 , 107, 60);
	_donebutton.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:0.0 alpha:1.0];
	[ _donebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
	[_donebutton setBackgroundImage:img_purchase forState:UIControlStateNormal];
	[_donebutton addTarget:self action:@selector(gotoctv:) forControlEvents:UIControlEventTouchUpInside];

	//個数マイナスボタン
    _subbutton = [[UIButton alloc] init];
    _subbutton.frame = CGRectMake((self.view.bounds.size.width - 90) * 0.75 - 10, self.view.bounds.size.height - 135, 40, 40);
    _subbutton.tintColor = [UIColor whiteColor];
    [ _subbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _subbutton setTitle:@"-" forState:UIControlStateNormal ];
    _subbutton.layer.cornerRadius = 20;
    _subbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    _subbutton.layer.borderWidth = 1;
    [_subbutton addTarget:self action:@selector(subcount:) forControlEvents:UIControlEventTouchUpInside];
	
	//個数プラスボタン
    _addbutton = [[UIButton alloc] init];
    _addbutton.frame = CGRectMake((self.view.bounds.size.width - 90) * 0.75 + 60, self.view.bounds.size.height - 135, 40, 40);
    _addbutton.tintColor = [UIColor whiteColor];
    [ _addbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _addbutton setTitle:@"+" forState:UIControlStateNormal ];
    _addbutton.layer.cornerRadius = 20;
    _addbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    _addbutton.layer.borderWidth = 1;
    [_addbutton addTarget:self action:@selector(addcount:) forControlEvents:UIControlEventTouchUpInside];
	
	//左の商品に戻るボタン
    _prebutton = [[UIButton alloc] init];
    _prebutton.frame = CGRectMake(5, self.view.bounds.size.height - 190, 40, 100);
    [ _prebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _prebutton setTitle:@"<" forState:UIControlStateNormal ];
    _prebutton.layer.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.45].CGColor;
    [_prebutton addTarget:self action:@selector(subindex:) forControlEvents:UIControlEventTouchUpInside];
	
	//右の商品に進むボタン
    _nextbutton = [[UIButton alloc] init];
    _nextbutton.frame = CGRectMake(self.view.bounds.size.width - 45, self.view.bounds.size.height - 190, 40, 100);
    [ _nextbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _nextbutton setTitle:@">" forState:UIControlStateNormal ];
    _nextbutton.layer.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.45].CGColor;
    [_nextbutton addTarget:self action:@selector(addindex:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons =  @[_scanbutton, _newsbutton, _donebutton, _subbutton, _addbutton, _prebutton, _nextbutton];
    for (UIButton *button in buttons) {
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:button];
    }

	// ラベル書き換え処理
	if([appDelegate getCount] > 0){
		NSLog(@"label index UPDATE: %d",labelindex);
		labelindex = [appDelegate getCount]-1;
		[self labelUpdate];
		
		NSLog(@"[viewdidload]product[0] name: %@, price: %@, amount: %@",[appDelegate getName:0],[appDelegate getPrice:0],[appDelegate getAmount:0]);
	}
}

// カメラを起動する
- (void)launchCamera
{
	_highlightView = [[UIView alloc] init];
	_highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
	_highlightView.layer.borderColor = [UIColor greenColor].CGColor;
	_highlightView.layer.borderWidth = 3;
	[self.view addSubview:_highlightView];
	
	_session = [[AVCaptureSession alloc] init];
	_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error = nil;
	
	_input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
	if (_input) {
		[_session addInput:_input];
	} else {
		NSLog(@"Error: %@", error);
	}
	
	_output = [[AVCaptureMetadataOutput alloc] init];
	[_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	[_session addOutput:_output];
	
	_output.metadataObjectTypes = [_output availableMetadataObjectTypes];
	
	_prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	_prevLayer.frame = CGRectMake(0, 64 , self.view.bounds.size.width, self.view.bounds.size.height - 264);
	_prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer:_prevLayer];
	
	[_session startRunning];
	
	[self.view bringSubviewToFront:_highlightView];
}

- (NSString *)barcode2product:(NSString *)barCode
{
	//バーコード値を投げてデータを格納
	NSString *queue = [NSString stringWithFormat:@"beacon_id=%@&barcode_id=%@",beaconId,barCode];
    NSString *url=[NSString stringWithFormat:@"http://54.64.69.224/api/v0/product?%@",queue];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    //値の代入
    NSString *name = [array valueForKeyPath:@"name"];
    NSString *price = [array valueForKeyPath:@"price"];

	// 値をDelegateの配列に格納
	[appDelegate setScanedProduct:name andPrice:price andBarCode:barCode];

	return @"Success";
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *barCode = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                barCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
		//バーコードスキャン成功したら商品を取得して保存
        if (barCode != nil)
        {
			int scanedNumber = [appDelegate getCountFromBarCode:barCode];
			NSLog(@"読み取ったバーコード値とかぶっている既存の配列値: %d",scanedNumber);
			if(scanedNumber == -1){//重複しなかった場合
				//バーコード値から商品情報を保存する関数を呼び出す
				[self barcode2product:barCode];
				//ラベルを更新
				labelindex = [appDelegate getCount]-1;
				[self labelUpdate];
			}else if(![[appDelegate getBarCode:[appDelegate getCount]-1] isEqualToString:barCode]){//重複しているが最新のスキャン内容ではなかったとき
				//個数を増やして商品を最新の位置に移動させる
				[appDelegate addAmount:scanedNumber];
				//商品の位置=最新の位置荷移動する
				labelindex = [appDelegate getCount]-1;
				[self labelUpdate];
			}//最新のスキャン内容とかぶっている場合は何もしない

			//バーコード値をリセット
			barCode = nil;
            break;
        }
    }
    _highlightView.frame = highlightViewRect;
}

//labelindexの位置にある商品のラベルを更新する
- (void)labelUpdate
{
	NSLog(@"[viewdidload]product[0] name: %@, price: %@, amount: %@",[appDelegate getName:0],[appDelegate getPrice:0],[appDelegate getAmount:0]);
	_namelabel.text = [appDelegate getName:labelindex];
	NSLog(@"[labelUpdate]labelindex: %d",labelindex);
	NSLog(@"_namelabel.text: %@",_namelabel.text);
	NSLog(@"products: %@",[appDelegate getScanedProduct:labelindex]);
	_pricelabel.text = [NSString stringWithFormat:@"¥%@",[appDelegate.products[labelindex][@"price"] stringValue]];
	_countlabel.text = [appDelegate.products[labelindex][@"amount"] stringValue];
}

//画面遷移ボタン
-(void)gotoctv:(UIButton *)button{
	PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pvc"];
    [self presentViewController:purchaseViewController animated:YES completion:nil];
}

//個数減らすボタン
-(void)subcount:(UIButton *)button{
	if([appDelegate getCount]!=0){
		// labelindexの商品の個数を1減らし、0個になったら削除する
		NSString *updatedAmount = [appDelegate subAmount:labelindex];
		//商品が削除されたとき
		if([updatedAmount isEqualToString:@"0"]){
			//スキャン済み商品が他にあれば最新商品に移動
			if([appDelegate getCount]>0){
				labelindex = [appDelegate getCount]-1;
				[self labelUpdate];
			}else{//スキャン済み商品がゼロになった場合ラベルを空にする
				labelindex = -1;
				_namelabel.text = @"";
				_pricelabel.text = @"";
				_countlabel.text = @"";
			}
		}else{//個数を減らしたが0にならなかった場合、最新の商品になっているので位置を更新
			labelindex = [appDelegate getCount]-1;
			[self labelUpdate];
		}
	}
}
//個数増やすボタン
-(void)addcount:(UIButton *)button{
	if([appDelegate getCount]!=0){
		//個数を増やして商品を最新の位置に移動させる
		[appDelegate addAmount:labelindex];
		//商品の位置=最新の位置荷移動する
		labelindex = [appDelegate getCount]-1;
		[self labelUpdate];
	}
}

//過去の商品履歴を見るボタン
-(void)subindex:(UIButton *)button{
    if(labelindex > 0){
		labelindex --;
		[self labelUpdate];
	}
}
-(void)addindex:(UIButton *)button{
    if(labelindex+1 < [appDelegate getCount]){
		labelindex ++;
		[self labelUpdate];
	}
}
@end
