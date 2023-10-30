//
//  BaseViewController.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/20.
//

import UIKit

class BaseViewController: UIViewController {

    var sendDate:NSString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        fatalError("init(coder:) has not been implemented")
    }
   
    static func initWithNib() -> Self{
        let vc = Self.init(nibName: String(describing: Self.self), bundle: nil)
        return vc
    }

}
