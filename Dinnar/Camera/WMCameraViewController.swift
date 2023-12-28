//
//  WMCameraViewController.swift
//  WMVideo
//
//  Created by wumeng on 2019/11/25.
//  Copyright © 2019 wumeng. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import Photos

enum WMCameraType {
    case video
    case image
    case imageAndVideo
}

class WMCameraViewController: BaseViewController {
    
    var url: String?
    var type: WMCameraType?
    var inputType:WMCameraType = WMCameraType.imageAndVideo
    var videoMaxLength: Double = 10
    var selectType:AlgorithmType = .detect
    var productId = ""
    var iouThreshold = 0.45
    var confidenceThreshold = 0.25
    var completeBlock: (DetailModel) -> () = {_  in }
    
    let previewImageView = UIImageView()
    var videoPlayer: WMVideoPlayer!
    var controlView: WMCameraControl!
    var manager: WMCameraManger!
    var timer: Timer?
    var timerCount:NSInteger = 0
    let cameraContentView = UIView()
    let thresholdValue:Double = 18
    var autoType:Bool = false
    
    var codeDetectModel=DetectModel(rect: CGRect())
    var bottomDetectModel=DetectModel(rect: CGRect())
    var circleDetectModel=DetectModel(rect: CGRect())
    var point:NSString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale: CGFloat = 16.0 / 9.0
        let contentWidth = UIScreen.main.bounds.size.width
        let contentHeight = min(scale * contentWidth, UIScreen.main.bounds.size.height)
        cameraContentView.backgroundColor = UIColor.black
        cameraContentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        cameraContentView.center = self.view.center
        self.view.addSubview(cameraContentView)
        print("\(contentWidth)-------\(contentHeight)");
        manager = WMCameraManger(superView: cameraContentView)
        setupView()
        
        if self.autoType {
            NotificationCenter.default.addObserver(self, selector: #selector(focreCameraPoint), name: NSNotification.Name("kFocreCameraPointKey"), object: nil)
        }
    }
    
    @objc func focreCameraPoint() {
        if self.autoType {
            self.controlView.autoType = self.autoType
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.controlView.autoTakephotosOp()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.startRunning()
        manager.focusAt(cameraContentView.center)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black
        cameraContentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(focus(_:))))
        cameraContentView.addGestureRecognizer(UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_:))))
        
        videoPlayer = WMVideoPlayer(frame: cameraContentView.bounds)
        videoPlayer.isHidden = true
        cameraContentView.addSubview(videoPlayer)
        
        
        previewImageView.frame = cameraContentView.bounds
        previewImageView.backgroundColor = UIColor.black
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.isHidden = true
        cameraContentView.addSubview(previewImageView)
        let height:CGFloat = (cameraContentView.wm_height - cameraContentView.wm_width)/2.0
        let maskView1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: cameraContentView.wm_width, height: height))
        maskView1.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        cameraContentView.addSubview(maskView1)
        let btnH:CGFloat = 30.0
        let btnW:CGFloat = 100.0
        let lampBtn = UIButton.init(frame: CGRect.init(x: maskView1.wm_width - btnW - 20, y: (maskView1.wm_height - btnH)/2.0, width: btnW, height: btnH))
        lampBtn.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
        lampBtn.setTitle("补光灯已连接", for: .normal)
        lampBtn.setTitleColor(UIColor.yellow, for: .normal)
        lampBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        lampBtn.layer.cornerRadius = btnH/2.0
        maskView1.addSubview(lampBtn)
        let maskView2 = UIView.init(frame: CGRect.init(x: 0, y: cameraContentView.wm_height - height, width: cameraContentView.wm_width, height: height))
        maskView2.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        cameraContentView.addSubview(maskView2)
        controlView = WMCameraControl.init(frame: CGRect(x: 0, y: cameraContentView.wm_height - 150, width: self.view.wm_width, height: 150))
        controlView.delegate = self
        controlView.videoLength = self.videoMaxLength
        controlView.inputType = self.inputType
        cameraContentView.addSubview(controlView)
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//            self.controlView.autoTakephotosOp()
//        }
        
    }
    
    @objc func focus(_ ges: UITapGestureRecognizer) {
        let focusPoint = ges.location(in: cameraContentView)
        manager.focusAt(focusPoint)
    }
    
    @objc func pinch(_ ges: UIPinchGestureRecognizer) {
        guard ges.numberOfTouches == 2 else { return }
        if ges.state == .began {
            manager.repareForZoom()
        }
        manager.zoom(Double(ges.scale))
    }
    
}

extension WMCameraViewController: WMCameraControlDelegate {
    
    func cameraControlDidComplete() {
        if self.selectType == .detect {//识别
            self.detectImg()//
        }else{
            self.segmentationImg()//分割
        }
    }
    
    func cameraControlDidTakePhoto() {
        manager.pickImage { [weak self] (imageUrl) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.type = .image
                self.url = imageUrl
                self.previewImageView.image = UIImage.init(contentsOfFile: imageUrl)
                self.previewImageView.isHidden = false
                self.controlView.showCompleteAnimation()
            }
        }
    }
    
    func cameraControlBeginTakeVideo() {
        manager.repareForZoom()
        manager.startRecordingVideo()
    }
    
    func cameraControlEndTakeVideo() {
        manager.endRecordingVideo { [weak self] (videoUrl) in
            guard let `self` = self else { return }
            let url = URL.init(fileURLWithPath: videoUrl)
            self.type = .video
            self.url = videoUrl
            self.videoPlayer.isHidden = false
            self.videoPlayer.videoUrl = url
            self.videoPlayer.play()
            self.controlView.showCompleteAnimation()
        }
    }
    
    func cameraControlDidChangeFocus(focus: Double) {
        let sh = Double(UIScreen.main.bounds.size.width) * 0.15
        let zoom = (focus / sh) + 1
        self.manager.zoom(zoom)
    }
    
    func cameraControlDidChangeCamera() {
        manager.changeCamera()
    }
    
    func cameraControlDidClickBack() {
        self.previewImageView.isHidden = true
        self.videoPlayer.isHidden = true
        self.videoPlayer.pause()
    }
    
    func cameraControlDidExit() {
        SerialGATT.shareInstance()?.turnOffTheLight()
//        self.dismiss(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
extension WMCameraViewController{
    func segmentationImg(){
        guard let imgUrl = self.url else {
            MBProgressHUD.showText("图片异常，请重新拍摄")
            return
        }
        let url = yolov5s_seg.urlOfModelInThisBundle
        let mmodel =  try? yolov5s_seg.init(contentsOf:url )
        let imageSize = CGSize.init(width: inputImgSize.width, height: inputImgSize.height)
        let image = UIImage.init(contentsOfFile: imgUrl)?.scaled(to: imageSize)
        let input = (try? yolov5s_segInput.init(imageWith: image!.cgImage!))!
        let result = try? mmodel?.prediction(input: input)
        print("var_949--->\(result?.var_949)")
        if let coo = result?.var_949,let co = result?.var_818 {            
            SataProcessing.init().letterboxOC(image,productId: self.productId, var_949: coo, var_818: co) { (image, array) in
                let model = DetailModel.init()
                if let  list = array as? [[AreaModel2]]{
                    for areas in list {
                        for area in areas {
                            model.group.append(area.toModel())
                        }
                    }
                }
                model.addTime = DateTool.dateToStr(date: Date())
                model.image = image
                model.productId = self.productId
                model.operatorName = DataTool.getUserName()
                if model.group.count == 0{
                    model.result = "1"
                } else{
                    model.result = "0"
                }

                DispatchQueue.main.async {
                    let detailVc = DetailsVC()
                    detailVc.model = model
                    detailVc.selectType = self.selectType
                    detailVc.autoType = self.autoType
                    self.navigationController?.pushViewController(detailVc, animated: true)
                }
            }
        }
    }
    
    func saveImage(image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { isSuccess, error in
            if isSuccess {
                
            } else {
                
            }
        }
    }
    
    func detectImg(){
        guard let imgUrl = self.url else {
//            MBProgressHUD.showText("图片异常，请重新拍摄")
            return
        }
        let preSecord = self.getCurrentMilliStamp()
        let url = swift_1207.urlOfModelInThisBundle
        guard let mmodel =  try? swift_1207.init(contentsOf:url ) else {
            return
        }
        var imageSize = CGSize.init(width: inputImgSize.width, height: inputImgSize.height)
        if let dic = mmodel.model.modelDescription.inputDescriptionsByName["image"] ,let h = dic.imageConstraint?.pixelsHigh,let w = dic.imageConstraint?.pixelsWide {
            imageSize.width = CGFloat(w)
            imageSize.height = CGFloat(h)
        }

        print("\(imageSize.width)-------------\(imageSize.height)")
//        let image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "123", ofType: "jpg")!)?.scaled(to: imageSize)
        let image = UIImage.init(contentsOfFile: imgUrl)?.scaled(to: imageSize)
        self.saveImage(image: image!)
//        let input = (try?swift_1110_v2Input.init(imageWith: (image?.cgImage!)!))!
        let input = (try?swift_1207Input.init(imageWith: (image?.cgImage!)!))!
        let result = try? mmodel.prediction(input: input)
        
        if let coo = result?.var_904 {
            SataProcessing.init().letterboxDetectOC(image,productId: self.productId, var_949: coo) { (image, array) in
                let model = DetailModel.init()
                if let  list = array as? [AreaModel2] {
                    for areas in list {
                        let aModel:AreaModel2 = areas
                        aModel.type = self.convertContentFromType(aModel.type as NSString) as String
                        model.group.append(aModel.toModel())
                    }
                }
                if model.group.count == 0{
                    model.result = "1"
                } else{
                    model.result = "0"
                }
                model.image = image;
                model.productId = self.productId
                self.saveImage(image: image!)
                let endSecord = self.getCurrentMilliStamp()
                model.handleTime = "\(endSecord - preSecord)"
                model.addTime = DateTool.dateToStr(date: Date())
                model.operatorName = DataTool.getUserName()
                DispatchQueue.main.async {
                    let detailVc = DetailsVC()
                    detailVc.model = model
                    detailVc.selectType = self.selectType
                    detailVc.autoType = self.autoType
                    print("point--->\(self.point)")
                    detailVc.point = self.point
                    self.navigationController?.pushViewController(detailVc, animated: true)
                }
                
            }
        }
    }
    
    func judgeCodeLocation(_ codeDetectModel:DetectModel, _ bottomDetectModel:DetectModel, _ imageSize:CGSize) -> (Bool) {
        var codeRect:CGRect = CGRect()
        var bottomRect:CGRect = CGRect()
        
        codeRect = codeDetectModel.rect
        print("code X:\(codeRect.origin.x)")
     
        bottomRect = bottomDetectModel.rect
        print("bottom X:\(bottomRect.origin.x)")
        
        var flag:Bool = false
        let codeX:Double = codeRect.origin.x*imageSize.width
        let codeY:Double = codeRect.origin.y*imageSize.width
        
        let bottomX:Double = bottomRect.origin.x*imageSize.width
        let bottomY:Double = bottomRect.origin.y*imageSize.width
        
        if codeX > bottomX {
            if codeX - bottomX > thresholdValue {
                flag = true
            }
        } else {
            if bottomX - codeX > thresholdValue {
                flag = true
            }
        }
        if flag == false {
            if codeY > bottomY {
                if codeY - bottomY > thresholdValue {
                    flag = true
                }
            } else {
                if bottomY - codeY > thresholdValue {
                    flag = true
                }
            }
        }
        
        return flag
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    func getCurrentMilliStamp()-> (CLongLong) {
        
        let timeInterval: TimeInterval = NSDate.now.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return millisecond
    }
    
    
    func convertContentFromType(_ num:NSString) ->(NSString) {
        var content:NSString
        
        if num.isEqual(to: "waste") {
            content = "废料"
        } else if num.isEqual(to: "impurity") {
            content = "毛丝杂质"
        } else {
            content = "二维码偏位"
        }
//        else {
//            content = "二维码缺失"
//        }
        return content
    }

//    func detectImg(){
//        guard let imgUrl = self.url else {
//            MBProgressHUD.showText("图片异常，请重新拍摄")
//            return
//        }
//        let url = m5d8_HSG.urlOfModelInThisBundle
//        guard let mmodel =  try? m5d8_HSG.init(contentsOf:url ) else {
//            return
//        }
//        var imageSize = CGSize.init(width: inputImgSize.width, height: inputImgSize.height)
//        if let dic = mmodel.model.modelDescription.inputDescriptionsByName["image"] ,let h = dic.imageConstraint?.pixelsHigh,let w = dic.imageConstraint?.pixelsWide {
//            imageSize.width = CGFloat(w)
//            imageSize.height = CGFloat(h)
//        }
//        var iouThreshold = 0.45
//        var confidenceThreshold = 0.25
//        guard let mateData = mmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as?[String:Any],let classes = mateData["classes"] as? String  else {
//            return
//        }
//        if let iou_threshold = mateData["iou_threshold"] as? String,let confidence_threshold = mateData["confidence_threshold"] as? String,let iou = Double(iou_threshold),let confidence = Double(confidence_threshold){
//            iouThreshold = iou
//            confidenceThreshold = confidence
//        }
//        print("\(imageSize.width)-------------\(imageSize.height)")
//        let image = UIImage.init(contentsOfFile: imgUrl)?.scaled(to: imageSize)
//        self.saveImage(image: image!)
//        let buff = ImageTool.buffer(from: image!)
//        let input = m5d8_HSGInput.init(image: buff!, iouThreshold: 0.45, confidenceThreshold: 0.25)
////        let input = (try? m5d8_HSGInput.init(imageWith: image!.cgImage!))!
//        let result = try? mmodel.prediction(input: input)
////        let input = m5d8_HSGInput.init(image: buff!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
//        let classArray = classes.components(separatedBy: ",")
//        DispatchQueue.global().async {
//            if let result = try? mmodel.prediction(input: input),let img = image{
//                DispatchQueue.main.async{
//                    let models = DataTool.detectModelArray(from: result, names: classArray)
//                    let image = ImageTool.drawRectangle(image: img, array: models)
//                    self.saveImage(image: image!)
//                    let model = DetailModel.init()
//                    model.addTime = DateTool.dateToStr(date: Date())
//                    model.image = image
//                    model.productId = self.productId
//                    model.operatorName = DataTool.getUserName()
//                    if models.count == 0{
//                        model.result = "1"
//                    }else{
//                        model.result = "0"
//                    }
//                    self.dismiss(animated: true) {
//                        self.completeBlock(model)
//                    }
//                    SerialGATT.shareInstance()?.turnOffTheLight()
//
//                }
//            }

//        }
//    }
}
