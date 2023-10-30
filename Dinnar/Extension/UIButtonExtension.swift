//
//  UIButtonExtension.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import Foundation
import UIKit
extension UIButton {
    ///设置下划线
    func underline() {
         guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
 
}
