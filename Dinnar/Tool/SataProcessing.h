//
//  SataProcessing.h
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreML/CoreML.h>

//#include "Dinnar-Swift.h"
@interface SataProcessing : NSObject

-(void)letterboxOC:(UIImage *)img productId:(NSString *)productId var_949:(MLMultiArray *)var_949 var_818:(MLMultiArray *)var_818  block:(void (^)(UIImage * image, NSMutableArray *array))block;


-(void)letterboxDetectOC:(UIImage *)img productId:(NSString *)productId var_949:(MLMultiArray *)var_949 block:(void (^)(UIImage * image, NSMutableArray *array))block ;

@end

