//
//  AVCaptureScale.m
//  Dinnar
//
//  Created by oneStep on 2023/10/19.
//

#import "AVCaptureScale.h"

@implementation AVCaptureScale

+ (CGFloat)changeVideoScale:(AVMetadataMachineReadableCodeObject *)avobjc {
    NSArray *array = avobjc.corners;
    CGPoint point = CGPointZero;
    int index = 0;
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    CGPoint point2 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[2], &point2);
    CGFloat scace =40/(point2.x-point.x);
    return scace;
}

@end
