//
//  Algorithm.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import UIKit
import CoreML
enum AlgorithmType {
    case detect
    case segmentation
}
class AlgorithmVC: BaseViewController {
    @IBOutlet weak var imgView: UIImageView!
    var imgUrl:String = ""
    var type:AlgorithmType = .detect

    override func viewDidLoad() {
        super.viewDidLoad()
        fenge1()

        // Do any additional setup after loading the view.
    }
    func fenge1(){
        let url = yolov5s_seg.urlOfModelInThisBundle
        let mmodel =  try? yolov5s_seg.init(contentsOf:url )
        let image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "640", ofType: "jpg")!)
        let input = (try? yolov5s_segInput.init(imageWith: image!.cgImage!))!
        let result = try? mmodel?.prediction(input: input)
        if let coo = result?.var_949,let co = result?.var_818{
            SataProcessing.init().letterboxOC(image, productId: "123", var_949: coo, var_818: co) { (image, array) in
                self.imgView.image = image
                let model = DetailModel.init()
                if let  list = array as? [[AreaModel]]{
                    for areas in list {
                        model.group.append(contentsOf: areas)
                    }
                }
                model.image = image
                model.operatorName = "user 0002"
                model.addTime = "2023-06-2000"
                model.productId = "9768798BLFD"
                let vc = DetailsVC.initWithNib()
                vc.model = model
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func detectImg(){
        let url = detect.urlOfModelInThisBundle
        guard let mmodel =  try? detect.init(contentsOf:url ) else {
            return
        }
        var imageSize = CGSize.init(width: inputImgSize.width, height: inputImgSize.height)
        if let dic = mmodel.model.modelDescription.inputDescriptionsByName["image"] ,let h = dic.imageConstraint?.pixelsHigh,let w = dic.imageConstraint?.pixelsWide {
            imageSize.width = CGFloat(w)
            imageSize.height = CGFloat(h)
        }
        var iouThreshold = 0.45
        var confidenceThreshold = 0.25
        guard let mateData = mmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as?[String:Any],let classes = mateData["classes"] as? String  else {
            return
        }
        if let iou_threshold = mateData["iou_threshold"] as? String,let confidence_threshold = mateData["confidence_threshold"] as? String,let iou = Double(iou_threshold),let confidence = Double(confidence_threshold){
            iouThreshold = iou
            confidenceThreshold = confidence
        }
        let image = UIImage.init(contentsOfFile: self.imgUrl)?.scaled(to: imageSize)
        let buff = ImageTool.buffer(from: image!)
        let input = detectInput.init(image: buff!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        let classArray = classes.components(separatedBy: ",")
        DispatchQueue.global().async {
            if let result = try? mmodel.prediction(input: input),let img = image{
                DispatchQueue.main.async{
//                    self.imgView.image = ImageTool.drawRectangle(image: img, array: DataTool.detectModelArray(from: result, names: classArray))
                }
            }
        }
    }
    func segmentationImg(){
        let url = segmentation.urlOfModelInThisBundle
        guard let mmodel =  try? segmentation.init(contentsOf:url ) else {
            return
        }
        var imageSize = CGSize.init(width: inputImgSize.width, height: inputImgSize.height)
        if let dic = mmodel.model.modelDescription.inputDescriptionsByName["image"] ,let h = dic.imageConstraint?.pixelsHigh,let w = dic.imageConstraint?.pixelsWide {
            imageSize.width = CGFloat(w)
            imageSize.height = CGFloat(h)
        }
        guard let metaData = mmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as?[String:Any],let paramsString = metaData["com.apple.coreml.model.preview.params"] as? String,let params = paramsString.tojson() as? [String:[String]] else {
            return
        }
        let image = UIImage.init(contentsOfFile: self.imgUrl)?.scaled(to: imageSize)
        let input = (try? segmentationInput.init(imageWith: image!.cgImage!))!
        DispatchQueue.global().async {
            if let result = try? mmodel.prediction(input: input) {
                DispatchQueue.main.async{
                    self.imgView.image = ImageTool.image(multiArray: result.semanticPredictions, previewParams: params)
                }
            }
        }
    }
}
