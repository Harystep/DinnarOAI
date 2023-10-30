//
//  UIViewControllerExt.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/15.
//

import Foundation
import UIKit
@objc extension UIViewController {
    @objc func showToast(_ message: String?, _ toview:UIView? = nil, _ duration: Double = 3.0) {
        if message == nil {
            return
        }
        var showView = self.view
        if view != nil {
            showView = view
        }
        MBProgressHUD.showText(message!, to: showView, afterDelay: Float(duration))
    }
    func showAlert(title:String?,msg:String?,cancelTitle:String = "取消",showCancel:Bool = true,sureTitle:String = "确定",sureBlock:(()->Void)?){
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        if showCancel {
            let cancelAction = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        let sureAcion = UIAlertAction.init(title: sureTitle, style: .default) { (action) in
            sureBlock?()
        }
        alert.addAction(sureAcion)
        self.present(alert, animated: true, completion: nil)
    }

}
