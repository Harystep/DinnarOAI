

import UIKit
import AVFoundation
let WJScreenWidth = UIScreen.main.bounds.size.width
let WJScreenHeight = UIScreen.main.bounds.size.height
let WJScanWidth:CGFloat = 260.0
class WJQRcode: BaseViewController {
    private var device:AVCaptureDevice!
    private var input :AVCaptureDeviceInput!
    private var output:AVCaptureMetadataOutput!
    private var captureSession:AVCaptureSession!
    private var preview:AVCaptureVideoPreviewLayer!
    private var videoDataOutput:AVCaptureVideoDataOutput!
    private var stillImageOutput:AVCaptureStillImageOutput!
    private var videoConnection:AVCaptureConnection!
    private var scanView:WJQRView!
    private var flashlightBtn:UIButton!
    private var focusView:UIView!
    private var wjSize:CGSize = CGSize(width: WJScanWidth, height: WJScanWidth)
    private var initialPinchZoom:CGFloat!
    private var labelReadying:UILabel!
    private var activityView:UIActivityIndicatorView!
    var completeBlock:((_ deviceId:String?)-> Void )?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialPinchZoom = 1.0
        initPreviewLayer()
        initAVCapture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scannerStart()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerStop()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scannerStop()
        removeActivityView()
    }
    // MARK:- 初始化扫描视图
    private func initPreviewLayer(){
        
        scanView = WJQRView(frame: CGRect(origin: CGPoint.zero, size: wjSize))
        scanView.center = CGPoint(x: WJScreenWidth / 2, y: WJScreenHeight / 2)
        self.view.addSubview(scanView)
        
        let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(recognizer:)))
        self.view.addGestureRecognizer(pinch)
        
        focusView = UIView.init()
        focusView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 80))
        focusView.center = CGPoint(x: scanView.frame.midX, y: scanView.frame.midY)
        scanView.addSubview(focusView)
        focusView.isHidden = true
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = UIColor.yellow.cgColor
        focusView.layer.borderWidth = 0.5
        
        flashlightBtn = UIButton(type: .custom)
        flashlightBtn?.setImage(UIImage(named: "lamp"), for: .normal)
        flashlightBtn?.setImage(UIImage(named: "lamp_select"), for: .selected)
        flashlightBtn?.isHidden = true
        flashlightBtn.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 40))
        flashlightBtn.center = CGPoint(x: scanView.frame.midX, y: scanView.frame.maxY - 30 - flashlightBtn.frame.height / 2)
        flashlightBtn?.addTarget(self, action: #selector(self.flashlightClick(sender:)), for: .touchUpInside)
        self.view.addSubview(flashlightBtn!)
                
        let titleL:UILabel = UILabel(frame: CGRect(x: 0, y: CGRectGetMinY(scanView.frame)-40, width: WJScreenWidth, height: 30))
        titleL.text = "扫描设备二维码，获取设备ID"
        titleL.textAlignment = .center
        self.view.addSubview(titleL)
        
        let backBtn:UIButton = UIButton()
        self.view.addSubview(backBtn)
        backBtn.frame = CGRect(x: 10, y: 40, width: 40, height: 40)
        backBtn.setImage(UIImage(named: "BackIcon"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        
    }
    
    // MARK:- 初始化activityView
    func deviceReadyingWithText(text:String) {
        if !(activityView != nil) {
            activityView = UIActivityIndicatorView()
            activityView.style = .gray
            labelReadying = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            labelReadying.textColor = UIColor.white
            labelReadying.font = UIFont.systemFont(ofSize: 18)
            labelReadying.textAlignment = .center
            labelReadying.text = text
            labelReadying.sizeToFit()
            activityView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
            labelReadying.bounds = CGRect(x: 0, y: 0, width: 100, height: 30)
            activityView.center  = self.view.center
            labelReadying.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 30)
            self.view.addSubview(activityView)
            self.view.addSubview(labelReadying)
            activityView.startAnimating()
        }
    }
    
    // MARK:- 初始化Capture
    private func initAVCapture() {
        do {
            device  = AVCaptureDevice.default(for: AVMediaType.video)
            input = try AVCaptureDeviceInput(device: device!)        
            
            output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            
            stillImageOutput = AVCaptureStillImageOutput()
            let outputSettings:Dictionary = [AVVideoCodecJPEG:AVVideoCodecKey]
            stillImageOutput?.outputSettings = outputSettings
            
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.high
          
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(output){
                captureSession.addOutput(output)
            }
            if captureSession.canAddOutput(videoDataOutput){
                captureSession.addOutput(videoDataOutput)
            }
            if captureSession.canAddOutput(stillImageOutput){
                captureSession.addOutput(stillImageOutput)
            }
            output.metadataObjectTypes = [.qr,.code39,.code93,.code128,.code39Mod43,.ean8,.ean13]
            preview = AVCaptureVideoPreviewLayer(session: captureSession)
            preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            preview.frame = self.view.bounds
            self.view.layer.insertSublayer(preview, at: 0)
            
            let toTopPercent = (WJScreenHeight - WJScanWidth)/2/WJScreenHeight
            let toLeftPercent = (WJScreenWidth - WJScanWidth)/2/WJScreenWidth
            let widthPercent = WJScanWidth/WJScreenWidth
            let heightPercent = WJScanWidth/WJScreenHeight
            output.rectOfInterest = CGRect(x: toTopPercent, y: toLeftPercent, width: heightPercent, height: widthPercent)
        } catch  {
            print("错误错误错误")
        }
    }
}

// MARK:- 自定义事件
extension WJQRcode {
    // MARK:- 启动扫码功能
    private func scannerStart(){
        captureSession.startRunning()
        scanView.startAnimation()
        
    }
    
    // MARK:- 关闭扫码功能
    private func scannerStop() {
        let error:NSError? = nil
        try? device.lockForConfiguration()
        if(!(error != nil)){
            device.videoZoomFactor = 1.0
            device.unlockForConfiguration()
        }
        captureSession.stopRunning()
        scanView.stopAnimation()
    }
    
    // MARK:- 删除activityView
    func removeActivityView() {
        if (activityView != nil) {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            labelReadying.removeFromSuperview()
            activityView = nil
            labelReadying = nil
        }
    }
    
    // MARK:- 点击相册功能
    @objc func selectPhotoFormPhotoLibrary(_ sender : AnyObject){
        scannerStop()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picture = UIImagePickerController()
            picture.sourceType = UIImagePickerController.SourceType.photoLibrary
            picture.sourceType = .savedPhotosAlbum
            picture.modalTransitionStyle = .coverVertical
            picture.delegate = self
            self.present(picture, animated: true, completion: nil)
        }else {
            let alertController = UIAlertController.init(title: "提示", message: "设备不支持访问相册，请在设置->隐私->照片中进行设置！", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "确定", style: .cancel) { (_) in }
            let cancelAction = UIAlertAction.init(title: "去设置", style: .default, handler: { alertAction in
                if WJCommon.canOpenSystemSetting(){
                    let settingUrl = NSURL(string: UIApplication.openSettingsURLString)!
                    if UIApplication.shared.canOpenURL(settingUrl as URL) {
                        UIApplication.shared.openURL(settingUrl as URL)
                    }
                }
            })
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
// MARK:- 代理事件
extension WJQRcode:AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        playSound()
        if metadataObjects.count > 0 {
          
            let metaData : AVMetadataMachineReadableCodeObject = self.preview.transformedMetadataObject(for: metadataObjects.last!) as! AVMetadataMachineReadableCodeObject
            print("result:\(String(describing: metaData.stringValue))")
            changeVideoScale(objc: metaData)
        } else {
//            let alertController = UIAlertController.init(title: "扫码结果", message: "没有扫描到结果", preferredStyle: .alert)
//            let confirmAction = UIAlertAction(title: "确定", style: .default) { (_) in }
//            alertController.addAction(confirmAction)
//            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict:CFDictionary? = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let metadata:Dictionary<String,Any>? = metadataDict as? Dictionary<String,Any>
        let exifMetadata:Dictionary<String,Any>? = metadata?[kCGImagePropertyExifDictionary as String] as? Dictionary<String,Any>
        let brightnessValue:CGFloat? = exifMetadata?[kCGImagePropertyExifBrightnessValue as String] as? CGFloat
        if let brightValue = brightnessValue {
            if brightValue < 0{
                setTorchBtn(enable: true)
            } else {
                setTorchBtn(enable: false)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.deviceReadyingWithText(text: "正在处理")
        picker.dismiss(animated: true) {
            let image = info[UIImagePickerController.InfoKey.originalImage.rawValue]
            let imageData = (image as! UIImage).pngData()
            let ciImage = CIImage(data: imageData!)
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            let array = detector?.features(in: ciImage!)
            if (array?.count)! > 0{
                let result : CIQRCodeFeature = array!.first as! CIQRCodeFeature
                let whitespace = NSCharacterSet.whitespacesAndNewlines
                let resultStr = result.messageString?.trimmingCharacters(in: whitespace)
                print("resultStr---->:\(resultStr)")
            }
        }
    }

}


// MARK:- 手动对焦
extension WJQRcode {
    private func playSound() {
        guard let soundUrl = Bundle.main.url(forResource: "声音文件", withExtension: nil)else {return}
        var soundID:SystemSoundID = 2
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if preview.isHidden {
            return
        }
        for touch:UITouch in (event?.allTouches)! {
            let point = touch.location(in: scanView)
            focusOn(point: point)
        }
    }

    func focusOn(point:CGPoint){
        let size:CGSize = scanView.bounds.size
        let pointofInterest = CGPoint(x: point.y/size.height, y: 1-point.x/size.width)
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            try? device.lockForConfiguration()
            device.focusMode = .autoFocus
            device.focusPointOfInterest = pointofInterest
        }
        if device.isExposureModeSupported(.autoExpose) {
            device.exposureMode = .autoExpose
            device.exposurePointOfInterest = pointofInterest
        }
        self.focusView.center = point
        device.unlockForConfiguration()
        focusView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.focusView.transform = .init(scaleX: 1.25, y: 1.25)
        }) { (finished:Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                self.focusView.transform = .identity
            }, completion: { (finshed:Bool) in
                self.focusView.isHidden = true
                
            })
        }
        
    }
   
}

// MARK:- 焦距调节
extension WJQRcode {
    @objc func handlePinchGesture(recognizer:UIPinchGestureRecognizer) {
        if (recognizer.state == .began) {
            initialPinchZoom = device.videoZoomFactor
        }
    }
    func videoZoomFactor(scale:CGFloat){
        let error:NSError? = nil
        try? device.lockForConfiguration()
        if(!(error != nil)){
            var zoomFactor:CGFloat!
            if(scale < 1.0){
                zoomFactor = initialPinchZoom - pow(device.activeFormat.videoMaxZoomFactor, 1-scale)
            }else {
                zoomFactor = initialPinchZoom + pow(device.activeFormat.videoMaxZoomFactor, (scale - 1.0) / 2.0)
            }
            zoomFactor = min(10.0, zoomFactor)
            zoomFactor = max(1.0, zoomFactor)
//            device.videoZoomFactor = zoomFactor
            //这样平滑一些
            device.ramp(toVideoZoomFactor: zoomFactor, withRate: 1)

            device.unlockForConfiguration()
            
        }
    }
    
    func changeVideoScale(objc:AVMetadataMachineReadableCodeObject) {
        let scale = AVCaptureScale.changeVideoScale(objc)
        if scale > 1 {
            videoZoomFactor(scale: scale)
        }else {
            self.scannerStop()
            let whitespace = NSCharacterSet.whitespacesAndNewlines
            let resultStr = objc.stringValue?.trimmingCharacters(in: whitespace)
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true) {
                    self.completeBlock?(resultStr)
                }
                
            })
        }

    }
    
    @objc func backBtnClick() {
        SerialGATT.shareInstance()?.turnOffTheLight()
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK:- 闪光灯
extension WJQRcode {
    @objc func flashlightClick(sender: UIButton){
        sender.isSelected = !sender.isSelected
        torch(isTurnON: sender.isSelected)
    }
    private func setTorchBtn(enable:Bool){
        guard let torchBtn = flashlightBtn, !flashlightBtn.isSelected else {
            return
        }
        torchBtn.isHidden = !enable
        if !enable {
            torch(isTurnON: false)
            torchBtn.isSelected = false
        }
    }
    private func torch(isTurnON:Bool) {
        guard let device = device else {
            return
        }
        if device.hasTorch {
            if isTurnON {
                try? device.lockForConfiguration()
                device.torchMode =  AVCaptureDevice.TorchMode.on
                device.unlockForConfiguration()
            } else {
                try? device.lockForConfiguration()
                device.torchMode =  AVCaptureDevice.TorchMode.off
                device.unlockForConfiguration()
            }
        }
    }
}








































