//
//  MBProgressHUD+SP.h
//  leyin
//
//  Created by Lizheng Pang on 2019/4/23.
//  Copyright © 2019 Changxu Zhuang. All rights reserved.
//

#import "MBProgressHUD.h"



@interface MBProgressHUD (SP)
+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

+(void)showText:(NSString *)text;
+(void)showText:(NSString *)text toView:(UIView *)view;
+(void)showText:(NSString *)text toView:(UIView *)view afterDelay:(float) afterDelay;
@end


