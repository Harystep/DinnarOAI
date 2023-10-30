//
//  YYAnimatedImageView+Extension.m
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/26.
//

#import "YYAnimatedImageView+Extension.h"
#import <objc/runtime.h>
@implementation YYAnimatedImageView (Extension)
+(void)load
{
    // hook：钩子函数
    Method method1 = class_getInstanceMethod(self, @selector(displayLayer:));
    
    Method method2 = class_getInstanceMethod(self, @selector(dx_displayLayer:));
    method_exchangeImplementations(method1, method2);
}

-(void)dx_displayLayer:(CALayer *)layer {
    
    if ([UIImageView instancesRespondToSelector:@selector(displayLayer:)]) {
        [super displayLayer:layer];
    }
    
}
@end
