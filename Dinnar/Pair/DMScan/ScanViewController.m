//
//  ScanViewController.m
//  ScanCodeDemo
//
//  Created by CL on 2019/6/10.
//  Copyright © 2019 CL. All rights reserved.
//

#import "ScanViewController.h"
#import "CLScanCodeManeger.h"
#import "CLScanAnimationView.h"
#import "SerialGATT.h"
//#import "WMCameraViewController-swift.h"

@interface ScanViewController ()

@property (strong, nonatomic) CLScanAnimationView *scanView;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat marginX = ([UIScreen mainScreen].bounds.size.width - 250)/2.0;
    CGFloat marginY = ([UIScreen mainScreen].bounds.size.height - 250)/2.0;
    self.scanView = [[CLScanAnimationView alloc] initWithFrame:CGRectMake(marginX, marginY, 250, 250)];
    [self.view addSubview:self.scanView];    
    		
	// 高级图片不变形拉伸
	UIImage *image = [UIImage imageNamed:@"qrcode_border"];
	CGFloat inset = 102.0/4;
	image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(inset, inset, inset, inset) resizingMode:UIImageResizingModeStretch];
	self.scanView.imageView.image = image;
	self.scanView.scanLine.image = [UIImage imageNamed:@"qrcode_scanline_barcode"];
	
	// 设置扫描识别区域(不是必要操作)
	[self.scanView.superview layoutIfNeeded];
	[[CLScanCodeManeger manager] setRecognitionAreaRect:self.scanView.frame];
	
	// 获取相机授权状态(不是必要操作)
	AVAuthorizationStatus authStatus = [[CLScanCodeManeger manager] captureDeviceAuthorizationStatus];
	if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
		//无权限
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"扫一扫需要开启应用相机权限" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
			
		}];
		[alertController addAction:cancelAction];
		[self presentViewController:alertController animated:YES completion:nil];
	}
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanNoneContentNotice) userInfo:nil repeats:NO];
	// 显示预览（必要）
    __weak typeof(self) weakself = self;
	[[CLScanCodeManeger manager] loadWithView:self.view resultHandler:^(NSString * _Nonnull result) {
		// 可以执行跳转到指定页了
        NSLog(@"result:--->%@", result);
        if(result.length > 0) {
            // 停止扫描动画
            [weakself stopTimerOp];
            [[CLScanCodeManeger manager] stopScan];
            [weakself.scanView stopAnimation];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    weakself.scanResultBack(result);
                }];
            });
        }
	}];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 40, 40)];
    [self.view addSubview:backBtn];
    [backBtn setImage:[UIImage imageNamed:@"BackIcon"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)scanNoneContentNotice {
    [self stopTimerOp];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSendClientDataKey" object:@"Next_NG"];
}

- (void)stopTimerOp {
    [self.timer invalidate];
    self.timer = nil;
    

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backBtnClick {
    [[SerialGATT shareInstance] turnOffTheLight];
    // 停止扫描
    [[CLScanCodeManeger manager] stopScan];
    // 停止扫描动画
    [self.scanView stopAnimation];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    // 开始扫描
    [[CLScanCodeManeger manager] startScan];
    // 开始扫描动画
    [self.scanView startAnimation];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

#pragma mark - 正则：是不是有效网址
- (BOOL)achiveStringWithWeb:(NSString *)urlString {
	NSString *regex = @"[a-zA-z]+://.*";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	return [predicate evaluateWithObject:urlString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
