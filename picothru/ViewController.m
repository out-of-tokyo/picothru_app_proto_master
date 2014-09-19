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
    UIButton *_button;
    UIButton *_button2;
    UIButton *_button3;
	Scanitems *scanitems;
	long long scan_barcode[100];
}
@end

@implementation ViewController
NSMutableArray *items;
NSArray *prodactname;
NSMutableArray *prodactprice;
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
	
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
	
	//カメラ起動してなんかやってる
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

	
    // 会計終了ボタン
    _button = [[UIButton alloc] init];
    _button.frame = CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80);
    _button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _button.backgroundColor = [UIColor greenColor];
    [ _button setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _button setTitle:@"確認&決済" forState:UIControlStateNormal ];
    _button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button addTarget:self action:@selector(hoge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _button2 = [[UIButton alloc] init];
    _button2.frame = CGRectMake(200, self.view.bounds.size.height - 110, 20, 20);
    _button2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _button2.tintColor = [UIColor whiteColor];
    [ _button2 setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _button2 setTitle:@"-" forState:UIControlStateNormal ];
    _button2.layer.cornerRadius = 10;
    _button2.layer.borderColor = [UIColor whiteColor].CGColor;
    _button2.layer.borderWidth = 1;
    _button2.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button2 addTarget:self action:@selector(hoge2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button2];
    
    _button3 = [[UIButton alloc] init];
    _button3.frame = CGRectMake(260, self.view.bounds.size.height - 110, 20, 20);
    _button3.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _button3.tintColor = [UIColor whiteColor];
    [ _button3 setTitleColor:[ UIColor whiteColor ] forState:UIControlStateNormal ];
    [ _button3 setTitle:@"+" forState:UIControlStateNormal ];
    _button3.layer.cornerRadius = 10;
    _button3.layer.borderColor = [UIColor whiteColor].CGColor;
    _button3.layer.borderWidth = 1;
    _button3.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button3 addTarget:self action:@selector(hoge3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button3];

    
    
    
	
	/////////////queueを作成/////////////
    //	NSString * queue;
    //	queue = @"store_id=1&barcode_id=4903326112852";
    //	[self barcode2product:(queue)];
    //	queue = @"store_id=2&barcode_id=4903326112853";
    //	[self barcode2product:(queue)];
	
    
	////////////////////////////////////
	
	
	
	
	
	/////////////ラベル書き換え(Coredata経由)/////////////
    //	[self new_itemlabel];
	////////////////////////////////////
    
	
	
    
}


- (NSString *)barcode2product:(NSString *)queue
{
	//バーコード値を投げてデータを格納
    NSString *url=[NSString stringWithFormat:@"http://54.64.69.224/api/v0/product?%@",queue];
	
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
	
    NSLog(@"array = %@",array);
	
	//値の代入
	scanitems = [Scanitems MR_createEntity];
    scanitems.prodacts = response;
    scanitems.names = [array valueForKeyPath:@"name"];
    scanitems.prices = [array valueForKeyPath:@"price"];
	scanitems.number = [NSNumber numberWithInt:1];
	
	NSLog(@"scanitems.number = %@",scanitems.number);
	NSLog(@"scanitems.prices = %@",scanitems.prices);
	
	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveNestedContexts];
    
	
	_namelabel.text = [NSString stringWithFormat:@"%@", scanitems.names];
    _pricelabel.text = [NSString stringWithFormat:@"%@円", scanitems.prices];
    _countlabel.text = [NSString stringWithFormat:@"%@", scanitems.number];
	//_namelabel.text = [NSString stringWithFormat:@"%@ %@円 %@点", scanitems.names, scanitems.prices, scanitems.number];
    
	return @"hoge";
	
}

- (NSString *)new_itemlabel
{
	//Coredata呼び出し
	id delegate = [[UIApplication sharedApplication] delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *d = [NSEntityDescription entityForName: @"Scanitems" inManagedObjectContext:_managedObjectContext];
	[fetchrequest setEntity:d];
    NSError *error_coredata = nil;
	
	//呼び出したCoredata格納
	NSArray *list;
    list = [moc executeFetchRequest:fetchrequest error:&error_coredata];
	
	//呼び出したCoredata分割格納
	//	NSLog(@"list##########%@##########",list);
    //	NSString *names = [[list valueForKeyPath:@"names"] objectAtIndex:0];
    //	NSString *prices = [[list valueForKeyPath:@"prices"] objectAtIndex:0];
    //	NSString *number = [[list valueForKeyPath:@"number"] objectAtIndex:0];
	NSString *names = [list valueForKeyPath:@"names"];
	NSString *prices = [list valueForKeyPath:@"prices"];
	NSString *number = [list valueForKeyPath:@"number"];
	//	NSString *names = @"hoge";
	//	NSString *prices = @"foo";
	//	NSString *number = @"bar";
	//	NSArray *names = [list valueForKeyPath:@"names"];
	//	NSArray *prices = [list valueForKeyPath:@"prices"];
	//	NSArray *number = [list valueForKeyPath:@"number"];
	
	//現在スキャン済みとされている商品一覧
	NSLog(@"names: %@",[[list valueForKeyPath:@"names"] description]);
	NSLog(@"prices: %@",[[list valueForKeyPath:@"prices"] description]);
	NSLog(@"number: %@",[[list valueForKeyPath:@"number"] description]);
	
	
    _namelabel.text = [NSString stringWithFormat:@"%@", names];
    _pricelabel.text = [NSString stringWithFormat:@"%@円", prices];
    _countlabel.text = [NSString stringWithFormat:@"%@", number];

    
	//_namelabel.text = [NSString stringWithFormat:@"%@ %@円 %@点", names, prices, number];
    
	return @"foo";
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
			NSLog(@"###############barcode: %@#################",detectionString);
            //			NSString *url=[NSString stringWithFormat:@"http://54.64.69.224/api/v0/product?store_id=1&barcode_id=%@", detectionString];
            //            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            //            NSData * response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            //            NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
            //            Scanitems *scanitems = [Scanitems MR_createEntity];
            //            scanitems.prodacts = response;
            //            scanitems.names = [array valueForKeyPath:@"name"];
            //            scanitems.prices = [array valueForKeyPath:@"price"];
            //            _label.text = [array valueForKeyPath:@"name"];
			
			detectionString = @"store_id=1&barcode_id=4903326112852";
            //			for(int i=0;i<[scan_barcode count];i++){
            //
            //
            //			}
            
			[self barcode2product:detectionString];
            
            //			[NSThread sleepForTimeInterval:1.0f];
			detectionString = nil;
			
            break;
        }
        else
            _namelabel.text = @"(none)";
    }
    
    _highlightView.frame = highlightViewRect;
}

-(void)hoge:(UIButton*)button{
    //Scanitems* scanitems = [Scanitems MR_createEntity];
    //NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:items];
    //NSData *nameData = [NSKeyedArchiver archivedDataWithRootObject:prodactname];
    //NSData *priceData = [NSKeyedArchiver archivedDataWithRootObject:prodactprice];
    //scanitems.prodacts = itemsData;
    //scanitems.names = nameData;
    //scanitems.prices = priceData;
    //	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    //    [context MR_saveNestedContexts];
    
    ConTableViewController *conTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ctv"];
    [self presentViewController:conTableViewController animated:YES completion:nil];
}
-(void)hoge2:(UIButton*)button{
	
    int temp = scanitems.number.intValue-1;
	scanitems.number = [NSNumber numberWithInt:temp];
	 _countlabel.text = [NSString stringWithFormat:@"%d", temp];
}
-(void)hoge3:(UIButton*)button{
	
    int temp = scanitems.number.intValue+1;
	scanitems.number = [NSNumber numberWithInt:temp];
    _countlabel.text = [NSString stringWithFormat:@"%d", temp];
}

@end
