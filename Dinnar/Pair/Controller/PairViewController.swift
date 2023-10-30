//
//  PairViewController.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/21.
//

import UIKit
enum  PairingStatus  {
    case startPairing
    case pairing
    case paired
}
class PairViewController: BaseViewController {
    var pairingStatus = PairingStatus.startPairing
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var decsLabel: UILabel!
    @IBOutlet weak var paireBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var navView: UIView!
    var intoType:NSInteger = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()        
        let sensor = SerialGATT.shareInstance()
        sensor!.delegate = self
        sensor!.setup()
        self.navView.addShadow(shadowColor: UIColor.black, shadowOpacity: 0.1, shadowRadius: 2, shadowOffset: CGSize.init(width: 0, height: 4))
        // Do any additional setup after loading the view.
    }
    private func setupSubviews() {
        switch pairingStatus {
        case .startPairing:
            titleLabel.text = "打开蓝牙"
            decsLabel.text = startPairingDescribe
            paireBtn.isHidden = false
            paireBtn.setTitle("开始配对", for: .normal)
            imgView.image = UIImage.init(named: "startPairing")
        case .pairing:
            titleLabel.text = "正在配对..."
            decsLabel.text = startPairingDescribe
            paireBtn.isHidden = true
            paireBtn.setTitle("开始配对", for: .normal)
            imgView.image = UIImage.init(named: "pairing")
        case .paired:
            titleLabel.text = "配对成功"
            decsLabel.text = pairedDescribe
            paireBtn.isHidden = false
            paireBtn.setTitle("完成", for: .normal)
            imgView.image = UIImage.init(named: "paired")
        }
    }
    @IBAction func paireBtnClick(){
        switch pairingStatus {
        case .startPairing:
            self.scaning()
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
//                self.pairingStatus = .paired
//                self.setupSubviews()
//            }
        case .paired:
            self.navigationController?.popViewController(animated: true)
            break
            
        default:
            break

        }
    }
    deinit {
        SerialGATT.shareInstance()?.delegate = nil
        
    }
    
}
extension PairViewController{
    
    func scaning(){
        
        let sensor = SerialGATT.shareInstance()!
        if sensor.activePeripheral != nil,sensor.activePeripheral.name == "OSTRAN"{
            if sensor.activePeripheral.state == .connected {
                pairingStatus = .paired
                setupSubviews()
            }
        }
        if sensor.peripheralState == .poweredOn {
            pairingStatus = .pairing
            setupSubviews()
            sensor.findBLKSoftPeripherals(30)
            return
        }
        var strMessage = "";
        var buttonTitle = "";
        switch (sensor.peripheralState) {
        case .unknown:
            strMessage = "手机没有识别到蓝牙，请检查手机。"
            buttonTitle = "前往设置";

        case .resetting:
            strMessage = "手机蓝牙已断开连接，重置中..."
            buttonTitle = "前往设置";
        case .unsupported:
            strMessage = "手机不支持蓝牙功能，请更换手机。"
        case .poweredOff:
            strMessage = "手机蓝牙功能关闭，请前往设置打开蓝牙及控制中心打开蓝牙。";
            buttonTitle = "前往设置";
        case .unauthorized:
            strMessage = "手机蓝牙功能没有权限，请前往设置。";
            buttonTitle = "前往设置";
               default:
                   break;
           }
        if buttonTitle.isEmpty{
            self.showToast(strMessage)
            return
        }
        self.showAlert(title: nil, msg: strMessage, cancelTitle: "取消", showCancel: true, sureTitle: buttonTitle) {
            let settingURL = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(settingURL!){
                UIApplication.shared.open(settingURL!, options: [:], completionHandler: nil)
            }
        }
           
    }
}
extension PairViewController:BTSmartSensorDelegate{
    func peripheralFound(_ peripheral: CBPeripheral!) {
        if let name = peripheral.name{
            print("mame:" +  name)
        }
        
        if peripheral.name == "OSTRAN"{
            let sensor = SerialGATT.shareInstance()!
            sensor.stopScan()
            sensor.activePeripheral = peripheral
            sensor.connect(peripheral)
        }
    }
    func scanTimeout() {
        showToast("没有找到相关蓝牙设备")
        pairingStatus = .startPairing
        setupSubviews()
    }
    func didDisconnect() {
        showToast("蓝牙已断开")
        pairingStatus = .startPairing
        setupSubviews()
    }
    func didConnect() {
        pairingStatus = .paired
        setupSubviews()
    }
    func didFailToConnect() {
        showToast("配对失败")
        pairingStatus = .startPairing
        setupSubviews()
    }
    func setConnect() {
        
    }
    func setDisconnect() {
        
    }
    func serialGATTCharValueUpdated(_ UUID: String!, value data: Data!) {
        
    }
    
//    - (void) peripheralFound:(CBPeripheral *)peripheral;
//    - (void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data;
//    - (void) setConnect;
//    - (void) setDisconnect;
    
}


