//
//  SelectLightVC.swift
//  Dinnar
//
//  Created by oneStep on 2023/10/19.
//

import UIKit

class SelectLightVC: BaseViewController {
    var inputType:WMCameraType = WMCameraType.imageAndVideo
    var selectType:AlgorithmType = .detect
    var productId = ""
    let sureBtn:UIButton = UIButton.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sureBtn)
        let width:NSInteger = NSInteger(UIScreen.main.bounds.width)
        let height:NSInteger = NSInteger(UIScreen.main.bounds.height)
        sureBtn.frame = CGRect(x: (width-100)/2, y: height-100, width: 100, height: 45)
        sureBtn.backgroundColor = .black
        sureBtn.layer.cornerRadius = 5
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        
    }
    
    @objc func sureBtnClick() {
        let vc = WMCameraViewController()//拍照
        vc.selectType = selectType
        vc.inputType = inputType
        vc.productId = productId
        vc.completeBlock = {[weak self] (model) in
            //image
            self?.toDetailsVC(model: model)
        }
        self.present(vc, animated: true,completion: {
//                self?.navigationController?.popViewController(animated: false)
        })
    }
    
    func toDetailsVC(model:DetailModel){
        let vc = DetailsVC.initWithNib()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
