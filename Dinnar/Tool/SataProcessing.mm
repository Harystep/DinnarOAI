//
//  SataProcessing.m
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/14.
//
#include "processing.h"
#import "SataProcessing.h"
#import "Dinnar-Swift.h"
#import "ConstOC.h"
#include <iostream>

@implementation SataProcessing

-(void)letterboxDetectOC:(UIImage *)img productId:(NSString *)productId var_949:(MLMultiArray *)var_949 block:(void (^)(UIImage * image, NSMutableArray *array))block {
    NSMutableArray * areas = [[NSMutableArray alloc]init];
    std::vector<float> paddings(3);
    cv::Mat image = [self cvMatFromUIImage:img];
    std::cout<<image.rows<<" "<<image.cols<<std::endl;
    cv::Mat resized_img = letterDetectbox(image, paddings);
    int a1 = [[var_949.shape objectAtIndex:1] intValue];
    int a2 = [[var_949.shape objectAtIndex:2] intValue];
    cv::Mat detect_buffer = cv::Mat(a1, a2, CV_32F,var_949.dataPointer);
    std::vector<cv::Rect2d> boxes;
    std::vector<int> class_ids;
    std::vector<float> class_scores;
    std::vector<float> confidences;
    std::vector<cv::Mat> masks;
    std::vector<int> indices;
    indices = boxDetectProcessing(detect_buffer, paddings, boxes, class_ids, class_scores, confidences, masks);
    // 输出vector中的元素
    cv::Rect2d box_2;
    cv::Rect2d box_3;
    cv::Rect2d box_4;
    for (size_t i = 0; i < indices.size(); i++) {
        int index = indices[i];
        int class_id = class_ids[index];
        if (class_id == 1||class_id == 0) {
            cv::rectangle(image, boxes[index], colors[class_id % 6], 2, 8);
            std::string label = class_namedetects[class_id] + ":" + std::to_string(confidences[index]);
            cv::putText(image, label, cv::Point(boxes[index].tl().x, boxes[index].tl().y - 10), cv::FONT_HERSHEY_SIMPLEX, .5, colors[class_id % 6]);
            
            AreaModel2 * model = [[AreaModel2 alloc]init];
            NSString * className = [NSString stringWithCString:class_namedetects[class_id].c_str() encoding:[NSString defaultCStringEncoding]];
            model.type = className;
            model.recordId = productId;
            model.area = [NSString stringWithFormat:@"%f", boxes[index].width*boxes[index].height];
            model.percentage = [NSString stringWithFormat:@"%f", (boxes[index].width*boxes[index].height*1.0/(image.rows*image.rows))];
            [areas addObject:model];
        }
        if (class_id == 2) {
            box_2 = boxes[index];            
        }
        if (class_id == 3) {
            box_3 = boxes[index];
        }
        if (class_id == 4) {
            box_4 = boxes[index];
        }
    }
    float marginx = 0.01*image.rows*0.5/0.3;
    
    float marginL = box_2.x - box_3.x;
    float marginT = box_2.y - box_3.y;
    float marginR = box_3.x+box_3.width-box_2.x-box_2.width;
    float marginB = box_3.y+box_3.height-box_2.y-box_2.height;
    
    if ((marginR > marginx) && (marginL>marginx) && (marginT > marginx) &&(marginB>marginx)) {
    } else {
        if (box_2.width>0) {            
            float centerX_2 = box_2.x + (box_2.width/2.0);
            float centerY_2 = box_2.y + (box_2.height/2.0);
            float centerX_3 = box_3.x + (box_3.width/2.0);
            float centerY_3 = box_3.y + (box_3.height/2.0);
            if (fabs(centerX_2-centerX_3)<marginx && fabs(centerY_2-centerY_3)<marginx) {
            } else {
                cv::rectangle(image, box_2, colors[2], 2, 8);
                AreaModel2 * model = [[AreaModel2 alloc]init];
                model.type = @"code";
                model.recordId = productId;
                model.area = [NSString stringWithFormat:@"%f", box_2.width*box_2.height];
                model.percentage = [NSString stringWithFormat:@"%f", (box_2.width*box_2.height*1.0/(image.rows*image.rows))];
                [areas addObject:model];
            }
        }
    }
    block([self UIImageFromCVMat:image],areas);

}

-(void)letterboxOC:(UIImage *)img productId:(NSString *)productId var_949:(MLMultiArray *)var_949 var_818:(MLMultiArray *)var_818  block:(void (^)(UIImage * image, NSMutableArray *array))block{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    NSMutableArray * areas = [[NSMutableArray alloc]init];
    std::vector<float> paddings(3);
    cv::Mat image = [self cvMatFromUIImage:img];
    cv::Mat masked_img;
    cv::Mat resized_img = letterbox(image, paddings);
    int a1 = [[var_949.shape objectAtIndex:1] intValue];
    int a2 = [[var_949.shape objectAtIndex:2] intValue];
    cv::Mat detect_buffer = cv::Mat(a1, a2, CV_32F,var_949.dataPointer);
    int b1 = [[var_818.shape objectAtIndex:1] intValue];
    int b2 = [[var_818.shape objectAtIndex:2] intValue];
    int b3 = [[var_818.shape objectAtIndex:3] intValue];
    cv::Mat proto_buffer(b1, b2 * b3, CV_32F, var_818.dataPointer);
    std::vector<cv::Rect> boxes;
    std::vector<int> class_ids;
    std::vector<float> class_scores;
    std::vector<float> confidences;
    std::vector<cv::Mat> masks;
    std::vector<int> indices;
    indices = boxProcessing(detect_buffer, paddings, boxes, class_ids, class_scores, confidences, masks);
    
    std::vector<cv::Mat> rgb_masks = maskProcessing(image, indices, proto_buffer, paddings, boxes, masks);
    
    for (size_t i = 0; i < indices.size(); i++) {
        int index = indices[i];
        int class_id = class_ids[index];
        
        cv::rectangle(image, boxes[index], colors[class_id % 6], 2, 8);
        std::string label = class_names[class_id] + ":" + std::to_string(class_scores[index]);
        cv::putText(image, label, cv::Point(boxes[index].tl().x, boxes[index].tl().y - 10), cv::FONT_HERSHEY_SIMPLEX, .5, colors[class_id % 6]);
        cv::addWeighted(image, 1, rgb_masks[i], 0.5, 0, image);
//         float rate =  [self matColorFind:rgb_masks[i]];
        
        [self matColorFind:rgb_masks[i] block:^(int area, float rate) {
            AreaModel2 * model = [[AreaModel2 alloc]init];
            model.area = [[NSString alloc] initWithFormat:@"%d",area];
            model.percentage = [[NSString alloc] initWithFormat:@"%f",rate];
            NSString * className = [NSString stringWithCString:class_names[class_id].c_str() encoding:[NSString defaultCStringEncoding]];
            model.type = className;
            model.recordId = productId;
            NSMutableArray * array =  [dic objectForKey:className];
            if (array == nil){
                array = [[NSMutableArray alloc] init];
                [dic setObject:array forKey:className];
                [areas addObject:array];
            }
            [array addObject:model];
        }];
    }
    block([self UIImageFromCVMat:image],areas);

}

/*
在图片里查找指定颜色的比例
*/
-(void) matColorFind:(cv::Mat) image block:(void (^)(int area,float rate))block{
    int num = 0;//记录颜色的像素点
    float rate;//要计算的百分率
    //遍历图片的每一个像素点
    for(int i = 0; i < image.rows;i++) //行数
    {
        for(int j = 0; j <image.cols;j++)   //列数
        {
            if((image.at<cv::Vec4b>(i, j)[0] == 0 &&
                image.at<cv::Vec4b>(i, j)[1] == 0 &&
                image.at<cv::Vec4b>(i, j)[2] == 0 &&
                image.at<cv::Vec4b>(i, j)[3] == 0))
            {
               
                num++;
            }
        }
    }
    int total = image.rows * image.cols;
    int area = total - num;
    rate =  (float)area/total;
    block(area,rate);
}

-(void)imageTopicSave:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        
    }
    else{
        ///图片未能保存到本地
    }
}
- (UIImage *)UIImageFromCVMat:(cv::Mat &)cvMat{
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    size_t elemsize = cvMat.elemSize();
    if (elemsize == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= (elemsize == 4) ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNone;
    }
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:elemsize * cvMat.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                 // width
                                        cvMat.rows,                 // height
                                        8,                          // bits per component
                                        8 * cvMat.elemSize(),       // bits per pixel
                                        cvMat.step[0],              // bytesPerRow
                                        colorSpace,                 // colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   // CGDataProviderRef
                                        NULL,                       // decode
                                        false,                      // should interpolate
                                        kCGRenderingIntentDefault   // intent
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
- (cv::Mat)cvMatFromUIImage:(UIImage *)image{
    BOOL hasAlpha = NO;
    CGImageRef imageRef = image.CGImage;
    CGImageAlphaInfo alphaInfo = (CGImageAlphaInfo)(CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask);
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    cv::Mat cvMat;
    CGBitmapInfo bitmapInfo;
    CGFloat cols = CGImageGetWidth(imageRef);
    CGFloat rows = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    if (numberOfComponents == 1){// check whether the UIImage is greyscale already
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    else {
        cvMat = cv::Mat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
        bitmapInfo = kCGBitmapByteOrder32Host;
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo                  // Bitmap info flags
                                                    );
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);     // decode
    CGContextRelease(contextRef);
    
    return cvMat;
}
@end
