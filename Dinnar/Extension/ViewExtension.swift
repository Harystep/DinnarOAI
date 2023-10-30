//
//  ViewExpand.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/20.
//

import Foundation
import UIKit
extension UIView{
    func setCornerRadius(cornerRadius:CGFloat,borderWidth:CGFloat,borderColor:UIColor){
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}
