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
    UIButton *_donebutton;
    UIButton *_subbutton;
    UIButton *_addbutton;
	Scanitems *scanitems;
}
@end

@implementation ViewController
NSMutableArray *items;
NSMutableArray *namearray;
NSMutableArray *pricearray;
NSMutableArray *countarray;
NSMutableArray *codearray;
NSArray *list;
NSInteger labelindex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //変数初期化処理
	codearray =[[NSMutableArray array]init];
    namearray = [[NSMutableArray alloc]init];
    pricearray = [[NSMutableArray alloc]init];
	countarray = [[NSMutableArray alloc]init];
    list = [[NSArray alloc]init];
    labelindex = 0;
    
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
    [_donebutton addTarget:self action:@selector(hoge:) forControlEvents:UIControlEventTouchUpInside];
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
    [_subbutton addTarget:self action:@selector(hoge2:) forControlEvents:UIControlEventTouchUpInside];
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
    [_addbutton addTarget:self action:@selector(hoge3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addbutton];
    
    //coredataの読み込み
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *d = [NSEntityDescription entityForName: @"Scanitems" inManagedObjectContext:_managedObjectContext];
    [fetchrequest setEntity:d];
    list = [moc executeFetchRequest:fetchrequest error:nil];
    if(list){
        namearray = [NSKeyedUnarchiver unarchiveObjectWithData:[list valueForKeyPath:@"names"]];
        pricearray = [NSKeyedUnarchiver unarchiveObjectWithData:[list valueForKeyPath:@"prices"]];
        countarray =[NSKeyedUnarchiver unarchiveObjectWithData:[list valueForKeyPath:@"counts"]];
        codearray = [NSKeyedUnarchiver unarchiveObjectWithData:[list valueForKeyPath:@"codes"]];
    }
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
    NSString *name = [array valueForKeyPath:@"name"];
    NSString *price = [array valueForKeyPath:@"price"];
    [namearray addObject:name];
    [pricearray addObject:price];
	[countarray addObject:[NSNumber numberWithInteger:1]];
	NSLog(@"scanitems.number = %@",namearray[labelindex]);
	NSLog(@"scanitems.prices = %@",pricearray[labelindex]);
	_namelabel.text = [NSString stringWithFormat:@"%@", namearray[labelindex]];
    _pricelabel.text = [NSString stringWithFormat:@"%@円", pricearray[labelindex]];
    _countlabel.text = [NSString stringWithFormat:@"%@", countarray[labelindex]];
    labelindex++;
    return @"hoge";
	
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
		//バーコードスキャン成功したら商品を取得して保存
        if (detectionString != nil)
        {
			//ダミーコード
			detectionString = @"store_id=1&barcode_id=4903326112852";
			if(![codearray containsObject:detectionString]){//重複しなかった場合
				//バーコード値を配列に保管
                [codearray addObject:detectionString];
				//バーコード値から商品情報を保存する関数を呼び出す
				[self barcode2product:detectionString];
			}else{
                [NSThread sleepForTimeInterval:0.5];
            }
			//バーコード値をリセット
			detectionString = nil;
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
}

-(void)hoge:(UIButton*)button{
    NSData *namesdata = [NSKeyedArchiver archivedDataWithRootObject:namearray];
    NSData *pricesdata = [NSKeyedArchiver archivedDataWithRootObject:pricearray];
    NSData *countsdata = [NSKeyedArchiver archivedDataWithRootObject:countarray];
    NSData *codesdata = [NSKeyedArchiver archivedDataWithRootObject:codearray];
    scanitems = [Scanitems MR_createEntity];
    scanitems.names = namesdata;
    scanitems.prices = pricesdata;
    scanitems.counts = countsdata;
    scanitems.codes = codesdata;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveNestedContexts];
    ConTableViewController *conTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ctv"];
    [self presentViewController:conTableViewController animated:YES completion:nil];
}
-(void)hoge2:(UIButton*)button{
	int tmp = [countarray[labelindex]intValue] - 1;
    NSNumber *tmpnum = [[NSNumber alloc] initWithInt:tmp];
    [countarray replaceObjectAtIndex:labelindex withObject:tmpnum];
    _countlabel.text = [NSString stringWithFormat:@"%@", countarray[labelindex]];
}
-(void)hoge3:(UIButton*)button{
	int tmp = [countarray[labelindex]intValue] + 1;
    NSNumber *tmpnum = [[NSNumber alloc] initWithInt:tmp];
    [countarray replaceObjectAtIndex:labelindex withObject:tmpnum];
    _countlabel.text = [NSString stringWithFormat:@"%@", countarray[labelindex]];

}

@end
