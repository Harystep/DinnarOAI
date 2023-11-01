//
//  SelectVC.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import UIKit

class SelectVC: BaseViewController {
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var lightItemTypeL: UILabel!
    @IBOutlet weak var segmentBtn: UIButton!
    @IBOutlet weak var detectBtn: UIButton!
    var selectType:AlgorithmType = .detect
    var intoType:Int32 = 1
    var temBtn:UIButton!
    var socketService = CocoaSocketClient()
    let blueSwitch:Bool = true
    var lightItemType:Int = 0//0:环光 1：rgb
    var lightNum:NSString = ""//灯光亮度
    var lightColorType:String = ""//rgb 灯光类型
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
        self.temBtn.isSelected = true
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
    
    @IBAction func selectLightType(_ sender: UIButton) {
        let vc = SelectLightVC()
        vc.completeBlock = { [weak self] type, mode, lightNum in
            self?.lightItemType = type!
            self?.lightColorType = mode!
            self?.lightNum = lightNum! as NSString
            if type == 1 {
                self?.lightItemTypeL.text = "RGB灯"
            } else {
                self!.lightItemTypeL.text = "环光灯"
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: -- 算法选择按钮点击事件
    @IBAction private func selectBtnClick(btn:UIButton){
        /* 蓝牙注释*/
        if self.blueSwitch == true {
            if let activePeripheral = SerialGATT.shareInstance()?.activePeripheral{
                if activePeripheral.state != .connected {
                    let vc = PairViewController.initWithNib()
                    if self.lightItemType == 1 {
                        vc.bluthName = "OSTRGB"
                    } else {
                        vc.bluthName = "OSTRAN"
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    return;
                }
                
            } else {
                let vc = PairViewController.initWithNib()
                if self.lightItemType == 1 {
                    vc.bluthName = "OSTRGB"
                } else {
                    vc.bluthName = "OSTRAN"
                }
                self.navigationController?.pushViewController(vc, animated: true)
                return;
            }
        }
        SerialGATT.shareInstance().lightType = Int32(self.lightItemType)
        SerialGATT.shareInstance().lightNum = self.lightNum as String
        SerialGATT.shareInstance().lighColor = self.lightColorType as String
        SerialGATT.shareInstance()?.turnOnTheLight()
        
        //TYPE2
        let codeVc = ScannerVC()
        codeVc.type = Int32(btn.tag)
        self.intoType = Int32(btn.tag)
        codeVc.autoType = self.temBtn.isSelected
        codeVc.lightItemType = self.lightItemType
        codeVc.lightType = self.lightColorType
        self.navigationController?.pushViewController(codeVc, animated: true)
        
    }
    
    func nextScanCodeOp(_ point:NSString) {
        SerialGATT.shareInstance().lightType = Int32(self.lightItemType)
        SerialGATT.shareInstance().lightNum = self.lightNum as String
        SerialGATT.shareInstance().lighColor = self.lightColorType as String
        SerialGATT.shareInstance()?.turnOnTheLight()
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

    @IBAction func historyBtnClick(){
        let vc = HistoryVC.initWithNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
