//
//  UIColorExtension.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/28.
//

import Foundation
import UIKit
extension UIColor{
    /// 十六进制的必须是 6 位 前两位 r 中间两位 g 后两位 b
    public static func color(hex:String) -> UIColor? {
        print("hex \(hex)")
        //16进制字符串转换10进制
        let text = Scanner.init(string: hex)
        
        var colorValue:UInt64 = 0
        text.scanHexInt64(&colorValue)
        print("colorValue \(colorValue)")
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        // 保留前两位 向右位移4位就是2 的16 次方 （16 进制每一位为 2 的4次方 总共 4个 2的4次方 一共为 2的16次方）
        red = CGFloat((colorValue & 0xFF0000)>>16)/0xFF
        // 保留中间两位 向右位移2位就是2 的8 次方
        green = CGFloat((colorValue & 0x00FF00)>>8)/0xFF
        // 保留后两位
        blue = CGFloat((colorValue & 0x0000FF))/0xFF
        
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
