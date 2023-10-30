//
//  TextFiledExt.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/24.
//

import Foundation
import UIKit
extension UITextField{
    func isEmpty() -> Bool{
        guard let str = self.text else {
            return true
        }
        let text = str.replacingOccurrences(of: " ", with: "")
        return text.isEmpty
    }
}
