//
//  SelectVC.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import UIKit

class SelectVC: BaseViewController {
    @IBOutlet weak var historyBtn: UIButton!
    var selectType:AlgorithmType = .detect
    var intoType:Int32 = 1
    var temBtn:UIButton!
    var socketService = CocoaSocketClient()
    let blueSwitch:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        historyBtn.underline()
        
        self.socketService.socketConnect()
        
        //1. 通知通讯（OC）
        NotificationCenter.default.addObserver(self, selector: #selector(notiReadBackData(_:)), name: NSNotification.Name("kReadClientDataKey"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notiSendBackData(_:)), name: NSNotification.Name("kSendClientDataKey"), object: nil)
        //添加开启自动功能按钮
        self.createAutoSwitchView()
        
//        SerialGATT.shareInstance().xorVerify()
        
//        let content:NSString = "Photo_1"
//        let itemArr:[String] = content.components(separatedBy: "_")
//        let key = itemArr.last! as NSString
//        print("key--->\(key)")
    }
    
    func createAutoSwitchView() {
        self.temBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 100, y: 85, width: 100, height: 40))
        self.temBtn.setTitle("开启自动", for: .normal)
        self.temBtn.setTitle("关闭自动", for: .selected)
        self.temBtn.addTarget(self, action: #selector(openAutoFunc), for: .touchUpInside)
        self.temBtn.setTitleColor(.red, for: .selected)
        self.temBtn.setTitleColor(.gray, for: .normal)
        self.view.addSubview(self.temBtn)
    }
    
    @objc func openAutoFunc() {        
        self.temBtn.isSelected = !self.temBtn.isSelected
    }
    
    @objc func notiSendBackData(_ data:Notification) {
        let content:NSString = data.object as! NSString
        self.socketService.sendMessageData(content as String)
    }
    @objc func notiReadBackData(_ data:Notification) {
        let content:NSString = data.object as! NSString
        print("\(content)")
        if content.contains("Photo") {//图片致拍照位
            let itemArr:[String] = content.components(separatedBy: "_")
            let pointNum:NSString = itemArr.last! as NSString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.nextScanCodeOp(pointNum)
            }
        } else if content.isEqual(to: "Finish") {//结束
            
        }
        
    }
    
    // MARK: -- 算法选择按钮点击事件
    @IBAction private func selectBtnClick(btn:UIButton){
        /* 蓝牙注释*/
        if self.blueSwitch == true {
            if let activePeripheral = SerialGATT.shareInstance()?.activePeripheral{
                if activePeripheral.state != .connected {
                    let vc = PairViewController.initWithNib()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return;
                }
                
            } else {
                let vc = PairViewController.initWithNib()
                
                self.navigationController?.pushViewController(vc, animated: true)
                return;
            }
        }
        SerialGATT.shareInstance()?.turnOnTheLight()
//        SerialGATT.shareInstance()?.turnOnTheRGBLight()
        
        
//        let scanVc = ScanViewController()
//        scanVc.type = Int32(btn.tag)
//        scanVc.scanResultBack = {(str) -> () in
//            let vc = WMCameraViewController()//拍照
//            if btn.tag == 0{
//                vc.selectType = .segmentation
//                self.selectType = .segmentation
//            }else{
//                vc.selectType = .detect
//                self.selectType = .detect
//            }
//            vc.autoType = self.temBtn.isSelected
//            vc.inputType = .image
//            vc.productId = str
//            vc.completeBlock = {[weak self] (model) in
//                //image
//                self?.toDetailsVC(model: model)
//            }
//            DispatchQueue.main.async {
//                self.present(vc, animated: true,completion:nil)
//            }
//        }
//        scanVc.modalPresentationStyle = .fullScreen
//        self.present(scanVc, animated: true, completion: nil)

        //TYPE1
//        let codeVc = ScanController()
//        codeVc.type = Int32(btn.tag)
//        self.intoType = Int32(btn.tag)
//        codeVc.autoType = self.temBtn.isSelected
//        self.navigationController?.pushViewController(codeVc, animated: true)
        
        //TYPE2
        let codeVc = ScannerVC()
        codeVc.type = Int32(btn.tag)
        self.intoType = Int32(btn.tag)
        codeVc.autoType = self.temBtn.isSelected
        self.navigationController?.pushViewController(codeVc, animated: true)
        
    }
    
    func nextScanCodeOp(_ point:NSString) {
        SerialGATT.shareInstance()?.turnOnTheLight()
//        let scanVc = ScanViewController()
//        scanVc.scanResultBack = {(str) -> () in
//            let vc = WMCameraViewController()//拍照
//            vc.selectType = self.selectType
//            vc.inputType = .image
//            vc.productId = str
//            vc.completeBlock = {[weak self] (model) in
//                //image
//                self?.toDetailsVC(model: model)
//            }
//            vc.autoType = self.temBtn.isSelected
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
//                self.present(vc, animated: true,completion: {
//
//                })
//            }
//        }
//        scanVc.modalPresentationStyle = .fullScreen
//        self.present(scanVc, animated: true, completion: nil)
        //step1
//        let codeVc = ScanController()
//        codeVc.type = self.intoType
//        codeVc.autoType = self.temBtn.isSelected
//        self.navigationController?.pushViewController(codeVc, animated: true)
        
        //TYPE2
        let codeVc = ScannerVC()
        codeVc.type = self.intoType
        codeVc.autoType = self.temBtn.isSelected
        codeVc.point = point
        self.navigationController?.pushViewController(codeVc, animated: true)
    }
    
    @IBAction private func logOut(){
       
        DataTool.logOut()
    }
    func toDetailsVC(model:DetailModel){
        let vc = DetailsVC.initWithNib()
        vc.model = model
        vc.selectType = self.selectType
        vc.autoType = self.temBtn.isSelected
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)
    }
    @IBAction func historyBtnClick(){
        let vc = HistoryVC.initWithNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
