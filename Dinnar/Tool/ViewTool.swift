//
//  ViewTool.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import Foundation
class ViewTool {
   static func currentWindow() -> UIWindow? {
    if let window = UIApplication.shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0})
        .first?.windows.first {
        return window
    }else if let window = UIApplication.shared.delegate?.window {
        return window
    }else{
        return nil
    }
   }
}
