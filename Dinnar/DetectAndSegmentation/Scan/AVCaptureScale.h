//
//  AVCaptureScale.h
//  Dinnar
//
//  Created by oneStep on 2023/10/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureScale : NSObject

+ (CGFloat)changeVideoScale:(AVMetadataMachineReadableCodeObject *)avobjc;

@end

NS_ASSUME_NONNULL_END
