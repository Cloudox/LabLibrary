//
//  ScanViewController.m
//  LabLibrary
//
//  Created by Cloudox on 15/9/14.
//  Copyright (c) 2015年 Cloudox. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import "AppDelegate.h"

@interface ScanViewController ()

@property (nonatomic, strong) UIView *tempView;

@property (nonatomic,strong) AppDelegate *myAppDelegate;// app委托

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Scan ISBN";
    
    // app委托
    self.myAppDelegate = [[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.tintColor = navigationBarColor;
    
    // 如果来自3D Touch，提供回到列表的按钮
    if (self.isFrom3DTouch) {
        UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStyleBordered target:self action:@selector(toList)];
        self.navigationItem.rightBarButtonItem = listButton;
    }
    
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置扫码作用区域，参数是区域占全屏的比例,x、y颠倒，高宽颠倒来设置= =什么鬼
    CGRect screenBounds = [ [ UIScreen mainScreen ] bounds ];
    [output setRectOfInterest:CGRectMake((screenBounds.size.height - (screenBounds.size.width - 60))/2/screenBounds.size.height, 30/screenBounds.size.width, (screenBounds.size.width - 60)/screenBounds.size.height, (screenBounds.size.width - 60)/screenBounds.size.width)];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    self.layer.frame=self.view.layer.bounds;// 设置照相显示的大小
    //    CGRect screenBounds = [ [ UIScreen mainScreen ] bounds ];
    //    self.layer.frame = CGRectMake(30, (screenBounds.size.height - (screenBounds.size.width - 60)) / 2, screenBounds.size.width - 60, screenBounds.size.width - 60);
    
    [self.view.layer insertSublayer:self.layer atIndex:0];// 设置层级，可以在扫码时显示一些文字
    
    //开始捕获
    [self.session startRunning];
    
    // 方框
    self.rectImage = [[UIImageView alloc]initWithFrame:CGRectMake(30, (screenBounds.size.height - (screenBounds.size.width - 60))/2, screenBounds.size.width - 60, screenBounds.size.width - 60)];
    self.rectImage.image = [UIImage imageNamed:@"scan_bg"];
    [self.view addSubview:self.rectImage];
    
    // 说明文字
    self.explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (screenBounds.size.height - (screenBounds.size.width - 60))/2 + screenBounds.size.width - 50, screenBounds.size.width - 60, 30)];
    self.explainLabel.textColor = [UIColor whiteColor];
    self.explainLabel.text = @"Aim the bar code to Scan";
    self.explainLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.explainLabel];
    
    // 线条动画
    self.upOrdown = NO;
    self.num =0;
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(70, (screenBounds.size.height - (screenBounds.size.width - 60))/2 + 10, screenBounds.size.width - 140, 2)];
    self.line.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:self.line];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tempView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated{
    //开始捕获
    [self.session startRunning];
}

// 回到列表界面
- (void)toList {
    [self.session stopRunning];
    [self.myAppDelegate changeToListViewController];
}

// 扫描线条动画
-(void)animation
{
    CGRect screenBounds = [ [ UIScreen mainScreen ] bounds ];
    if (self.upOrdown == NO) {
        self.num ++;
        self.line.frame = CGRectMake(70, (screenBounds.size.height - (screenBounds.size.width - 60))/2 + 10 +2*self.num, screenBounds.size.width - 140, 2);
        if (2*self.num == 280) {
            self.upOrdown = YES;
        }
    }
    else {
        self.num --;
        self.line.frame = CGRectMake(70, (screenBounds.size.height - (screenBounds.size.width - 60))/2 + 10 +2*self.num, screenBounds.size.width - 140, 2);
        if (self.num == 0) {
            self.upOrdown = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate Methods
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        //[session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
        // 关闭扫描，退出扫描界面
        [self.session stopRunning];
//        [self.layer removeFromSuperlayer];
        
        // 去掉扫描显示的内容
//        [self.timer invalidate];
//        [self.line removeFromSuperview];
//        [self.rectImage removeFromSuperview];
//        [self.explainLabel removeFromSuperview];
//        [self.navigationController popViewControllerAnimated:YES];
        
        
        // 必须通过storyboard来找到view！
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.isFromScan = YES;
        detailVC.isbn = metadataObject.stringValue;
        detailVC.nadrNum = @"";
        detailVC.bookTitle = @"";
        
        // 动画弹出
        self.tempView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT / 2 - 2, SCREENWIDTH, 4)];
        self.tempView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.tempView];
        // 进行一秒钟的动画
        [UIView animateWithDuration:0.3 animations:^{
            self.tempView.transform = CGAffineTransformMakeScale(1.0, SCREENHEIGHT / 4);
        }];
        
        double delayInSeconds = 0.2;
        __block ScanViewController* bself = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [bself.navigationController pushViewController:detailVC animated:NO];
        });
    }
}


@end
