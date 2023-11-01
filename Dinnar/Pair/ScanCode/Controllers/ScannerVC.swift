//
//  ScannerVC.swift
//  SwiftScanner
//
//  Created by Jason on 2018/11/30.
//  Copyright © 2018 Jason. All rights reserved.
//

import UIKit
import AVFoundation

public class ScannerVC: UIViewController {
    
    var type:Int32 = 0
    var autoType:Bool = false
    var timer:Timer!
    var point:NSString = ""
    var lightType:String = ""
    var lightItemType:Int = 0 //0:环光 1：rgb
    public lazy var headerViewController:HeaderVC = .init()
    
    public lazy var cameraViewController:CameraVC = .init()
    
    /// 动画样式
    public var animationStyle:ScanAnimationStyle = .default{
        didSet{
            cameraViewController.animationStyle = animationStyle
        }
    }
    
    // 扫描框颜色
    public var scannerColor:UIColor = .red{
        didSet{
            cameraViewController.scannerColor = scannerColor
        }
    }
    
    public var scannerTips:String = ""{
        didSet{
           cameraViewController.scanView.tips = scannerTips
        }
    }
    
    /// `AVCaptureMetadataOutput` metadata object types.
    public var metadata = AVMetadataObject.ObjectType.metadata {
        didSet{
            cameraViewController.metadata = metadata
        }
    }
    
    public var successBlock:((String)->())?
    
    public var errorBlock:((Error)->())?
    
    
    /// 设置标题
    public override var title: String?{
        
        didSet{
            
            if navigationController == nil {
                headerViewController.title = title
            }
        }
        
    }
    
    
    /// 设置Present模式时关闭按钮的图片
    public var closeImage: UIImage?{
        
        didSet{
            
            if navigationController == nil {
                headerViewController.closeImage = closeImage ?? UIImage()
            }
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let backBtn = UIButton(frame: CGRect(x: 10, y: 40, width: 40, height: 40))
        backBtn.setImage(UIImage(named: "BackIcon"), for: .normal)
        self.view.addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(scanNoneContentNotice), userInfo: nil, repeats: false)
    }
        
    @objc func scanNoneContentNotice() {
        self.stopTimerOp()
        let content:NSString = "Next_NG_\(self.point)" as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kSendClientDataKey"), object: content)
        SerialGATT.shareInstance()?.turnOffTheLight()
        self.navigationController?.popViewController(animated: true)
    }
    
    func stopTimerOp() {
        self.timer.invalidate()
    }
    
    @objc func backBtnClick() {
        
        SerialGATT.shareInstance()?.turnOffTheLight()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraViewController.startCapturing()
    }
    
}

// MARK: - CustomMethod
extension ScannerVC{
    
    func setupUI() {
        
        if title == nil {
            title = "扫一扫"
        }
        
        view.backgroundColor = .black
        
        headerViewController.delegate = self
        
        cameraViewController.metadata = metadata
        
        cameraViewController.animationStyle = animationStyle
        
        cameraViewController.delegate = self
        
        add(cameraViewController)
        
        if navigationController == nil {
            
            add(headerViewController)
            
            view.bringSubviewToFront(headerViewController.view)
            
        }
        
    }
    
    public func setupScanner(_ title:String? = nil, _ color:UIColor? = nil, _ style:ScanAnimationStyle? = nil, _ tips:String? = nil, _ success:@escaping ((String)->())){
        
        if title != nil {
            self.title = title
        }
        
        if color != nil {
            scannerColor = color!
        }
        
        if style != nil {
            animationStyle = style!
        }
        
        if tips != nil {
            scannerTips = tips!
        }
        
        successBlock = success
        
    }
}

// MARK: - HeaderViewControllerDelegate
extension ScannerVC:HeaderViewControllerDelegate{
    
    
    /// 点击关闭
    public func didClickedCloseButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}



extension ScannerVC:CameraViewControllerDelegate{
    
    func didOutput(_ code: String) {
        print("code---->\(code)")
        self.stopTimerOp()
        self.jumpCameraVC(code as NSString)
    }
    
    func didReceiveError(_ error: Error) {
        
        errorBlock?(error)
        
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
        print("point--->\(self.point)")
        vc.point = self.point
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
