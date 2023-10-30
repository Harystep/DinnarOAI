//
//  ScanViewController.h
//  ScanCodeDemo
//
//  Created by CL on 2019/6/10.
//  Copyright © 2019 CL. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ScanViewController : UIViewController

/** 扫描完成，自动跳转到网页 */
@property (nonatomic, assign) BOOL autoJump;

@property (nonatomic,copy) void (^scanResultBack)(NSString *content);

@property (nonatomic,assign) int type;

@end

NS_ASSUME_NONNULL_END
