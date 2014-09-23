//
//  ViewController.m
//  picothru
//
//  Created by Masaru Iwasa on 2014/09/10.
//  Copyright (c) 2014年 Masaru. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "ConTableViewController.h"
#import "Entity.h"
#import "ConViewController.h"
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
    UIButton *_donebutton;
    UIButton *_subbutton;
    UIButton *_addbutton;
    UIButton *_nextbutton;
    UIButton *_prebutton;
	Scanitems *scanitems;
	AppDelegate *appDelegate;
	
	//iBeacon
	NSString * beaconId;
}
@end

@implementation ViewController
NSMutableArray *codearray;
NSInteger labelindex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//デリゲート生成
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	beaconId = @"D87CEE67-C2C2-44D2-A847-B728CF8BAAAD";
	
	
    //変数初期化処理
	codearray =[[NSMutableArray array]init];
    labelindex = -1;
    
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
    _prevLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 180);
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_namelabel];
	
	// スキャン履歴表示ラベル
    _namelabel = [[UILabel alloc] init];
    _namelabel.frame = CGRectMake(0, self.view.bounds.size.height - 160, self.view.bounds.size.width, 40);
    _namelabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _namelabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _namelabel.textColor = [UIColor whiteColor];
    _namelabel.textAlignment = NSTextAlignmentCenter;
    _namelabel.text = @"";
    [self.view addSubview:_namelabel];
    
    _pricelabel = [[UILabel alloc] init];
    _pricelabel.frame = CGRectMake(0, self.view.bounds.size.height - 120, self.view.bounds.size.width * 1/2, 40);
    _pricelabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _pricelabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _pricelabel.textColor = [UIColor whiteColor];
    _pricelabel.textAlignment = NSTextAlignmentCenter;
    _pricelabel.text = @"";
    [self.view addSubview:_pricelabel];
    
    _countlabel = [[UILabel alloc] init];
    _countlabel.frame = CGRectMake(self.view.bounds.size.width * 1/2, self.view.bounds.size.height - 120, self.view.bounds.size.width * 1/2, 40);
    _countlabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _countlabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _countlabel.textColor = [UIColor whiteColor];
    _countlabel.textAlignment = NSTextAlignmentCenter;
    _countlabel.text = @"0";
    [self.view addSubview:_countlabel];

    _donebutton = [[UIButton alloc] init];
    _donebutton.frame = CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80);
    _donebutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _donebutton.backgroundColor = [UIColor greenColor];
    [ _donebutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _donebutton setTitle:@"確認&決済" forState:UIControlStateNormal ];
    _donebutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_donebutton addTarget:self action:@selector(gotoctv:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_donebutton];
    
    _subbutton = [[UIButton alloc] init];
    _subbutton.frame = CGRectMake(200, self.view.bounds.size.height - 110, 20, 20);
    _subbutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _subbutton.tintColor = [UIColor whiteColor];
    [ _subbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _subbutton setTitle:@"-" forState:UIControlStateNormal ];
    _subbutton.layer.cornerRadius = 10;
    _subbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    _subbutton.layer.borderWidth = 1;
    _subbutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_subbutton addTarget:self action:@selector(subcount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_subbutton];
    
    _addbutton = [[UIButton alloc] init];
    _addbutton.frame = CGRectMake(260, self.view.bounds.size.height - 110, 20, 20);
    _addbutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _addbutton.tintColor = [UIColor whiteColor];
    [ _addbutton setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _addbutton setTitle:@"+" forState:UIControlStateNormal ];
    _addbutton.layer.cornerRadius = 10;
    _addbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    _addbutton.layer.borderWidth = 1;
    _addbutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_addbutton addTarget:self action:@selector(addcount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addbutton];
    
    _prebutton = [[UIButton alloc] init];
    _prebutton.frame = CGRectMake(0, self.view.bounds.size.height - 160, 30, 80);
    _prebutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [ _prebutton setTitleColor:[ UIColor orangeColor ] forState:UIControlStateNormal ];
    [ _prebutton setTitle:@"<" forState:UIControlStateNormal ];
    _prebutton.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _prebutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_prebutton addTarget:self action:@selector(subindex:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_prebutton];
    
    _nextbutton = [[UIButton alloc] init];
    _nextbutton.frame = CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height - 160, 30, 80);
    _nextbutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [ _nextbutton setTitleColor:[ UIColor orangeColor ] forState:UIControlStateNormal ];
    [ _nextbutton setTitle:@">" forState:UIControlStateNormal ];
    _nextbutton.layer.backgroundColor= [UIColor whiteColor].CGColor;
    _nextbutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_nextbutton addTarget:self action:@selector(addindex:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextbutton];
	
}

- (NSString *)barcode2product:(NSString *)queue
{
	//バーコード値を投げてデータを格納
    NSString *url=[NSString stringWithFormat:@"http://54.64.69.224/api/v0/product?%@",queue];

    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    //値の代入
    NSString *name = [array valueForKeyPath:@"name"];
    NSString *price = [[array valueForKeyPath:@"price"] stringValue];

	// 値をDelegateの配列に格納
	[appDelegate setScanedProduct:name andPrice:price];
	_namelabel.text = [NSString stringWithFormat:@"%@", name];
    _pricelabel.text = [NSString stringWithFormat:@"%@円", price];
    _countlabel.text = @"1";

	return @"hoge";
	
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *barCode = nil;
	NSString *detectionString;
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
			//ダミーコード
			detectionString = [NSString stringWithFormat:@"beacon_id=%@&barcode_id=%@",beaconId,barCode];
			if(![codearray containsObject:detectionString]){//重複しなかった場合
				//バーコード値を配列に保管
                [codearray addObject:detectionString];
				//バーコード値から商品情報を保存する関数を呼び出す
				[self barcode2product:detectionString];
			}

			//バーコード値をリセット
			barCode = nil;
            break;
        }
    }
    _highlightView.frame = highlightViewRect;
}

//画面遷移ボタン
-(void)gotoctv:(UIButton*)button{
	ConViewController *conViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"convc"];
    [self presentViewController:conViewController animated:YES completion:nil];
}

//個数減らすボタン
-(void)subcount:(UIButton*)button{
	// 一番最近スキャンした商品の個数を1減らす
	NSString * updatedNumber = [appDelegate subNumber:[appDelegate getCount]-1];
	if([updatedNumber isEqualToString:@"0"]){
		_namelabel.text = @"";
		_pricelabel.text = @"";
	}
	_countlabel.text = updatedNumber;
}
//個数増やすボタン
-(void)addcount:(UIButton*)button{
	NSString * updatedNumber = [appDelegate addNumber:[appDelegate getCount]-1];
	_countlabel.text = updatedNumber;

}


//以下未実装
-(void)subindex:(UIButton*)button{
    if(labelindex > 0){
    labelindex --;
//    _namelabel.text = [NSString stringWithFormat:@"%@", namearray[labelindex]];
//    _pricelabel.text = [NSString stringWithFormat:@"%@円", pricearray[labelindex]];
//    _countlabel.text = [NSString stringWithFormat:@"%@", countarray[labelindex]];
    }
}
-(void)addindex:(UIButton*)button{
//    if(labelindex > [namearray count]){
//    labelindex ++;
//    _namelabel.text = [NSString stringWithFormat:@"%@", namearray[labelindex]];
//    _pricelabel.text = [NSString stringWithFormat:@"%@円", pricearray[labelindex]];
//    _countlabel.text = [NSString stringWithFormat:@"%@", countarray[labelindex]];
//    }
}

@end
