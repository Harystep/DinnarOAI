//
//  ScanVC.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import UIKit

class ScanVC: BaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var scanView: UIView?
    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    fileprivate var capture: ZXCapture?
    fileprivate var isScanning: Bool?
    fileprivate var isFirstApplyOrientation: Bool?
    fileprivate var captureSizeTransform: CGAffineTransform?
    var completeBlock:((_ deviceId:String?)-> Void )?
    var videoCurrentZoom: Double = 1.0    
    var videoZoomFactorScale:Double = 0    
    // MARK: Life Circles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let capture = self.capture,let isScanning = isScanning{
            if isScanning,!capture.running{
                self.capture?.start()
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let capture = self.capture,let isScanning = isScanning{
            if !isScanning,capture.running{
                self.capture?.stop()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstApplyOrientation == true { return }
        isFirstApplyOrientation = true
        applyOrientation()
//        capture?.captureDevice.videoZoomFactor = capture?.captureDevice.maxAvailableVideoZoomFactor ?? 1
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            // do nothing
        }) { [weak self] (context) in
            guard let weakSelf = self else { return }
            weakSelf.applyOrientation()
        }
    }
    
    // MARK: -- 返回按钮点击事件
    @IBAction func backBtnClick(){
        SerialGATT.shareInstance()?.turnOffTheLight()
        self.dismiss(animated: true, completion: nil)
    }
    deinit {
        print("释放了")
    }
}


// MARK: Helpers
extension ScanVC {
    
    func setup() {
        isScanning = false
        isFirstApplyOrientation = false
        capture = ZXCapture()
        guard let _capture = capture else { return }
        _capture.camera = _capture.back()
        _capture.focusMode =  .continuousAutoFocus
        _capture.delegate = self
        
        self.view.layer.addSublayer(_capture.layer)
        guard let _scanView = scanView, let _backBtn = backBtn, let _titleLabel = titleLabel else { return }
        _scanView.isUserInteractionEnabled = false
        self.view.bringSubviewToFront(_scanView)
        self.view.bringSubviewToFront(_titleLabel)
        self.view.bringSubviewToFront(_backBtn)
        self.view.addGestureRecognizer(UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_:))))
    }
    
    @objc func pinch(_ ges: UIPinchGestureRecognizer) {
        guard ges.numberOfTouches == 2 else { return }
        if ges.state == .began {
            repareForZoom()
        }
        zoom(Double(ges.scale))
    }
    
    func repareForZoom() {
        guard  let captureDevice = capture?.captureDevice else{return}
        videoCurrentZoom = Double(captureDevice.videoZoomFactor)
    }
    
    func zoom(_ mulriple: Double) {
        guard  let captureDevice = capture?.captureDevice else{return}
        let videoMaxZoomFactor = min(10, captureDevice.activeFormat.videoMaxZoomFactor)
        let toZoomFactory = max(1, Double(videoCurrentZoom) * mulriple)
        let finalZoomFactory = min(toZoomFactory, Double(videoMaxZoomFactor))
        lockForConfiguration { (device) in
            device.videoZoomFactor = CGFloat(finalZoomFactory)
        }
    }
    func lockForConfiguration(_ closure: (AVCaptureDevice) -> ()) {
        guard  let captureDevice = capture?.captureDevice else{return}
        do {
            try captureDevice.lockForConfiguration()
            closure(captureDevice)
            captureDevice.unlockForConfiguration()
        } catch {
            
        }
    }
    func applyOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        var captureRotation: Double
        var scanRectRotation: Double
        
        switch orientation {
            case .portrait:
                captureRotation = 0
                scanRectRotation = 90
                break
            
            case .landscapeLeft:
                captureRotation = 90
                scanRectRotation = 180
                break
            
            case .landscapeRight:
                captureRotation = 270
                scanRectRotation = 0
                break
            
            case .portraitUpsideDown:
                captureRotation = 180
                scanRectRotation = 270
                break
            
            default:
                captureRotation = 0
                scanRectRotation = 90
                break
        }
        
        applyRectOfInterest(orientation: orientation)
        
        let angleRadius = captureRotation / 180.0 * Double.pi
        let captureTranform = CGAffineTransform(rotationAngle: CGFloat(angleRadius))
        
        capture?.transform = captureTranform
        capture?.rotation = CGFloat(scanRectRotation)
        capture?.layer.frame = view.frame
    }
    
    func applyRectOfInterest(orientation: UIInterfaceOrientation) {
        guard var transformedVideoRect = scanView?.frame,
            let cameraSessionPreset = capture?.sessionPreset
            else { return }
        
        var scaleVideoX, scaleVideoY: CGFloat
        var videoHeight, videoWidth: CGFloat
        
        // Currently support only for 1920x1080 || 1280x720
        if cameraSessionPreset == AVCaptureSession.Preset.hd1920x1080.rawValue {
            videoHeight = 1080.0
            videoWidth = 1920.0
        } else {
            videoHeight = 720.0
            videoWidth = 1280.0
        }
        
        if orientation == UIInterfaceOrientation.portrait {
            scaleVideoX = self.view.frame.width / videoHeight
            scaleVideoY = self.view.frame.height / videoWidth
            
            // Convert CGPoint under portrait mode to map with orientation of image
            // because the image will be cropped before rotate
            // reference: https://github.com/TheLevelUp/ZXingObjC/issues/222
            let realX = transformedVideoRect.origin.y;
            let realY = self.view.frame.size.width - transformedVideoRect.size.width - transformedVideoRect.origin.x;
            let realWidth = transformedVideoRect.size.height;
            let realHeight = transformedVideoRect.size.width;
            transformedVideoRect = CGRect(x: realX, y: realY, width: realWidth, height: realHeight);
        
        } else {
            scaleVideoX = self.view.frame.width / videoWidth
            scaleVideoY = self.view.frame.height / videoHeight
        }
        
        captureSizeTransform = CGAffineTransform(scaleX: 1.0/scaleVideoX, y: 1.0/scaleVideoY)
        guard let _captureSizeTransform = captureSizeTransform else { return }
        let transformRect = transformedVideoRect.applying(_captureSizeTransform)
        capture?.scanRect = transformRect
    }
    
    func barcodeFormatToString(format: ZXBarcodeFormat) -> String {
        switch (format) {
            case kBarcodeFormatAztec:
                return "Aztec"
            
            case kBarcodeFormatCodabar:
                return "CODABAR"
            
            case kBarcodeFormatCode39:
                return "Code 39"
            
            case kBarcodeFormatCode93:
                return "Code 93"
            
            case kBarcodeFormatCode128:
                return "Code 128"
            
            case kBarcodeFormatDataMatrix:
                return "Data Matrix"
            
            case kBarcodeFormatEan8:
                return "EAN-8"
            
            case kBarcodeFormatEan13:
                return "EAN-13"
            
            case kBarcodeFormatITF:
                return "ITF"
            
            case kBarcodeFormatPDF417:
                return "PDF417"
            
            case kBarcodeFormatQRCode:
                return "QR Code"
            
            case kBarcodeFormatRSS14:
                return "RSS 14"
            
            case kBarcodeFormatRSSExpanded:
                return "RSS Expanded"
            
            case kBarcodeFormatUPCA:
                return "UPCA"
            
            case kBarcodeFormatUPCE:
                return "UPCE"
            
            case kBarcodeFormatUPCEANExtension:
                return "UPC/EAN extension"
            
            default:
                return "Unknown"
            }
    }
}

// MARK: ZXCaptureDelegate
extension ScanVC: ZXCaptureDelegate {
    func captureCameraIsReady(_ capture: ZXCapture!) {
        isScanning = true
        lockForConfiguration { (device) in
            device.videoZoomFactor = CGFloat(videoZoomFactorScale)
        }
    }
    
    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        guard let _result = result, isScanning == true else { return }
        capture?.stop()
        isScanning = false
//        let text = _result.text ?? "Unknow"
//        let format = barcodeFormatToString(format: _result.barcodeFormat)
//        let displayStr = "Scanned !\nFormat: \(format)\nContents: \(text)"
//        resultLabel?.text = displayStr
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        guard let text = _result.text else {
            return
        }
        self.dismiss(animated: true) {
            self.completeBlock?(text)
        }
    }
    
    
}
