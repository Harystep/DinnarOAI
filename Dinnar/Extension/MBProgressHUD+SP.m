//
//  MBProgressHUD+SP.m
//  leyin
//
//  Created by Lizheng Pang on 2019/4/23.
//  Copyright © 2019 Changxu Zhuang. All rights reserved.
//

#import "MBProgressHUD+SP.h"

@implementation MBProgressHUD (SP)
/**
 *  =======显示信息
 *  @param text 信息内容
 *  @param icon 图标
 *  @param view 显示的视图
 */
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    
    //    hud.label.textColor = Color333333;
    //hud.bezelView.style = MBProgressHUDBackgroundStyleSolidCo;
    hud.label.font = [UIFont systemFontOfSize:17.0];
    hud.userInteractionEnabled= NO;
    
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];  // 设置图片
    //    hud.bezelView.backgroundColor = mainGrayColor;    //背景颜色
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

/**
 *  =======显示 提示信息
 *  @param success 信息内容
 */
+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

/**
 *  =======显示
 *  @param success 信息内容
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

/**
 *  =======显示错误信息
 */
+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}
/**
 *  显示提示 + 菊花
 *  @param message 信息内容
 *  @return 直接返回一个MBProgressHUD， 需要手动关闭(  ?
 */
+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

/**
 *  显示一些信息
 *  @param message 信息内容
 *  @param view    需要显示信息的视图
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    
    return hud;
}

/**
 *  手动关闭MBProgressHUD
 */
+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
/**
 *  @param view    显示MBProgressHUD的视图
 */
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    
    [self hideHUDForView:view animated:YES];
}
+(void)showText:(NSString *)text
{
    [self showText:text toView:nil];
}
+(void)showText:(NSString *)text afterDelay:(float) afterDelay
{
    [self showText:text toView:nil afterDelay:afterDelay];
}
// 快速显示一个提示信息
+(void)showText:(NSString *)text toView:(UIView *)view{
    [self showText:text toView:view afterDelay:1.5];
}
// 快速显示一个提示信息
+(void)showText:(NSString *)text toView:(UIView *)view afterDelay:(float) afterDelay
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    [view addSubview:hud];
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont systemFontOfSize:13];
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:afterDelay];
}
@end
