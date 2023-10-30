//
//  ScanController.swift
//  Dinnar
//
//  Created by oneStep on 2023/10/25.
//

import UIKit

class ScanController: BaseViewController {
    var type:Int32 = 0
    var autoType:Bool = false
    var scanView = CLScanAnimationView()
    var timer:Timer!
    override func viewWillAppear(_ animated: Bool) {
        // 开始扫描
        CLScanCodeManeger.manager().startScan()
        // 开始扫描动画
        self.scanView.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        let marginX = (UIScreen.main.bounds.size.width - 250)/2.0
        let marginY = (UIScreen.main.bounds.size.height - 250)/2.0
        self.scanView.frame = CGRect(x: marginX, y: marginY, width: 250, height: 250)
        self.view.addSubview(self.scanView)
                
        // 高级图片不变形拉伸
        var image = UIImage(named: "qrcode_border")
        let inset = 102.0/4;
        image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), resizingMode: .stretch)
        self.scanView.imageView.image = image;
        self.scanView.scanLine.image = UIImage(named: "qrcode_scanline_barcode")
        
        // 设置扫描识别区域(不是必要操作)
        CLScanCodeManeger.manager().recognitionAreaRect = self.scanView.frame

        // 获取相机授权状态(不是必要操作)
        
        let authStatus = CLScanCodeManeger.manager().captureDeviceAuthorizationStatus()
        if (authStatus == .restricted || authStatus == .denied) {
            //无权限
            let alertController = UIAlertController.init(title: "温馨提示", message: "扫一扫需要开启应用相机权限", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction.init(title: "确认", style: .cancel)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated:true)
            
        }
        
        CLScanCodeManeger.manager().load(with: self.view) { result in
            let content:NSString = result as NSString
            if content.length > 0 {
                // 停止扫描动画
                self.stopTimerOp()
                CLScanCodeManeger.manager().stopScan()
                self.scanView.stopAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.jumpCameraVC(content)
                }
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(scanNoneContentNotice), userInfo: nil, repeats: false)
    }
    
    func jumpCameraVC(_ str:NSString) {
        let vc = WMCameraViewController()//拍照
        if self.type == 0 {
            vc.selectType = .segmentation
        } else {
            vc.selectType = .detect
        }
        vc.autoType = self.autoType
        vc.inputType = .image
        vc.productId = str as String
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func scanNoneContentNotice() {
        self.stopTimerOp()
        self.navigationController?.popViewController(animated: true)
    }
    
    func stopTimerOp() {
        self.timer.invalidate()        
    }
    
}
