//
//  ImageTool.swift
//  MLModelTest
//
//  Created by Lizheng Pang on 2023/5/17.
//

import Foundation
import CoreML
import UIKit
class ImageTool {
    static func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }
      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)
      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      return pixelBuffer
    }
    static func drawRectangle(image: UIImage,array:[DetectModel]) -> UIImage?{
        UIGraphicsBeginImageContext(CGSize.init(width: image.size.width, height: image.size.height))
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.init(x: 0, y: 0))
        let imgWidth = image.size.width
        let imgHeight = image.size.height                
        for model in  array {
            let rect = model.rect
//            print("rect----->\(model.rect)")
            let width = rect.size.width * imgWidth
            let height = rect.size.height * imgHeight
//            let x = (rect.origin.x) * imgWidth - width/2.0
//            let y = (rect.origin.y) * imgHeight - height/2.0
            let x = (rect.origin.x-0.010) * imgWidth - width/2.0
            let y = (rect.origin.y-0.00345) * imgHeight - height/2.0
            let path = CGMutablePath()
                /**绘制矩形的边界*/
            let rectangle = CGRect.init(x: x, y:y, width: width, height: height)
                /**将矩形添加到路径中*/
                path.addRect(rectangle)
                /**获取当前上下文句柄*/
            context?.addPath(path)
        }
            /**设置填充颜色*/
        UIColor.red.setFill()
            /**设置边框颜色*/
        UIColor.yellow.setStroke()
            /**设置线宽*/
        context?.setLineWidth(2)
            /**在上下文毛边并填充路径*/
        context?.drawPath(using: .stroke)
//        // 画文字
        let attr = [NSAttributedString.Key.foregroundColor: UIColor.red,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),NSAttributedString.Key.backgroundColor:UIColor.yellow]
        for model in  array {
            let rect = model.rect
            let width = rect.size.width * imgWidth
            let height = rect.size.height * imgHeight
            let x = rect.origin.x * imgWidth - width/2.0
            let y = rect.origin.y * imgHeight - height/2.0
            let text = model.labelName + String.init(format: " %f ", model.confidence)
            var ly = y - 15
            if ly < 0{
                ly = y
            }
            (text as NSString).draw(at: CGPoint(x: x, y:ly), withAttributes: attr)
        }
        let outPutImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outPutImg
    }
    
    static func image(multiArray: MLMultiArray,previewParams:[String:[String]]) -> UIImage {
        let shape = multiArray.shape
        let width = shape[0].intValue
        let height = shape[1].intValue
        let bitsPerComponent = 8
        let depth = 4
        let bitsPerPixel = bitsPerComponent * depth
        let bytesPerRow = width * bitsPerPixel / 8
        
        let dataPointer = multiArray.dataPointer
        let dataCount = multiArray.count
        let data32Arr  = dataPointer.bindMemory(to: UInt32.self, capacity: dataCount);
        
        let outputLength = dataCount * depth
        let outputArr = UnsafeMutableRawPointer.allocate(byteCount: outputLength, alignment: 0).bindMemory(to: UInt8.self, capacity: outputLength)
        
        for i in 0 ..< dataCount {
            let this = CGFloat(data32Arr[i])
            if this > 0 {
                outputArr[i * depth + 0] = 255
               
            }else{
                outputArr[i * depth + 0] = 0
            }
            
            outputArr[i * depth + 1] = 0
            outputArr[i * depth + 2] = 0
            if this > 0 {
                outputArr[i * depth + 3] = UInt8(100)
            }else{
                outputArr[i * depth + 3] = UInt8(0)
            }
            
        }
        
        let dataRef = CFDataCreate(nil, outputArr, outputLength)
        let dataProviderRef = CGDataProvider(data: dataRef!)
        
        let ref = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: .byteOrder16Big, provider: dataProviderRef!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let newImage = UIImage(cgImage: ref!)
        return newImage
    }
    static func saveImg(image:UIImage?) -> String?{
        if  let img = image {
            let path =  NSHomeDirectory() + "/Documents/cache.jpg:"
            if let imgData = img.jpegData(compressionQuality: 0.75) as NSData?{
                if imgData.write(toFile: path,atomically: true){
                    return path
                }
            }
        }
        return nil
    }
   
}

