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
    var completeBlock:((_ itemType:Int?, _ mode:String?, _ lightNum:String?)-> Void )?
    var modeView:UIView = UIView()
    var sourceView:UIView = UIView()
    var lightTypeSelectBtn:UIButton = UIButton()
    var lightModeSelectBtn:UIButton = UIButton()
    var lightSourceType:Int = 0
    var lightColor:String = "01"
    var lightColorNum:String = "100"
    var lightNumText:UITextField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: statusHeight+44))
        self.view.addSubview(navView)
        navView.backgroundColor = .white
        navView.addShadow(shadowColor: UIColor.black, shadowOpacity: 0.1, shadowRadius: 2, shadowOffset: CGSize.init(width: 0, height: 4))
        self.view.addSubview(sureBtn)
        
        
        sureBtn.frame = CGRect(x: (screenWidth-140)/2, y: screenHeight-100, width: 140, height: 45)
        sureBtn.backgroundColor = .black
        sureBtn.layer.cornerRadius = 22.5
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        
        self.createNavSubViews(navView)
        
        self.view.addSubview(self.sourceView)
        self.sourceView.frame = CGRect(x: 0, y: statusHeight+44+30, width: screenWidth, height: 90)
        self.view.addSubview(self.modeView)
        self.modeView.frame = CGRect(x: 0, y: CGRectGetMaxY(self.sourceView.frame)+40, width: screenWidth, height: 90+90+40)
        self.modeView.isHidden = true
        
        self.createSourceViewSubviews()
        
        self.createModeViewSubviews()
                
    }
    
    func createSourceViewSubviews() {
        let titleL = UILabel(frame: CGRect(x: 40, y: 0, width: 120, height: 25))
        titleL.text = "光源设置"
        titleL.font = UIFont.systemFont(ofSize: 18)
        self.sourceView.addSubview(titleL)
        
        let itemBtn = UIButton(frame: CGRect(x: 40, y: CGRectGetMaxY(titleL.frame)+20, width: 147, height: 44))
        itemBtn.setTitleColor(.black, for: .normal)
        itemBtn.setTitleColor(.white, for: .selected)
        itemBtn.setTitle("环光灯", for: .normal)
        itemBtn.layer.cornerRadius = 22
        itemBtn.backgroundColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
        self.sourceView.addSubview(itemBtn)
        itemBtn.tag = 0
        itemBtn.isSelected = true
        itemBtn.addTarget(self, action: #selector(itemBtnClick(_:)), for: .touchUpInside)
        self.setupTargetBtnStatus(true, itemBtn)
        self.lightTypeSelectBtn = itemBtn
        
        let rgbBtn = UIButton(frame: CGRect(x: CGRectGetMaxX(itemBtn.frame)+30, y: statusHeight, width: 147, height: 44))
        rgbBtn.setTitleColor(.black, for: .normal)
        rgbBtn.setTitleColor(.white, for: .selected)
        rgbBtn.setTitle("RGB", for: .normal)
        rgbBtn.layer.cornerRadius = 22
        rgbBtn.backgroundColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
        self.sourceView.addSubview(rgbBtn)
        rgbBtn.tag = 1
        rgbBtn.addTarget(self, action: #selector(itemBtnClick(_:)), for: .touchUpInside)
    }
    
    @objc func itemBtnClick(_ sender:UIButton) {
        if self.lightTypeSelectBtn == sender {
            return
        } else {
            sender.isSelected = true
            self.setupTargetBtnStatus(true, sender)
            self.lightTypeSelectBtn.isSelected = false
            self.setupTargetBtnStatus(false, self.lightTypeSelectBtn)
            self.lightTypeSelectBtn = sender
            
            self.lightSourceType = sender.tag
            if sender.tag == 1 {
                self.modeView.isHidden = false
            } else {
                self.modeView.isHidden = true
            }
        }
    }
    
    func createModeViewSubviews() {
        let titleL = UILabel(frame: CGRect(x: 40, y: 0, width: 120, height: 25))
        titleL.text = "选择模式"
        titleL.font = UIFont.systemFont(ofSize: 18)
        self.modeView.addSubview(titleL)
        let itemArr:[String] = ["白", "红", "绿", "蓝"]
        let widthContent:Double = (screenWidth - 80 - 32*3)/4.0
        for index in 0..<itemArr.count {
            
            let itemBtn = UIButton(frame: CGRect(x: 40+(widthContent+32)*Double(index), y: CGRectGetMaxY(titleL.frame)+20, width: widthContent, height: 44))
            itemBtn.setTitleColor(.black, for: .normal)
            itemBtn.setTitleColor(.white, for: .selected)
            itemBtn.setTitle(itemArr[index], for: .normal)
            itemBtn.layer.cornerRadius = 22
            itemBtn.backgroundColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
            self.modeView.addSubview(itemBtn)
            itemBtn.tag = index
            itemBtn.addTarget(self, action: #selector(modeBtnClick(_:)), for: .touchUpInside)
            if index == 0 {
                itemBtn.isSelected = true
                self.setupTargetBtnStatus(true, itemBtn)
                self.lightModeSelectBtn = itemBtn
            }
            
        }
        
        let subL = UILabel(frame: CGRect(x: 40, y: 90+30, width: 120, height: 25))
        subL.text = "亮度设置"
        subL.font = UIFont.systemFont(ofSize: 18)
        self.modeView.addSubview(subL)
        
        self.lightNumText = UITextField(frame: CGRect(x: 40, y: CGRectGetMaxY(subL.frame)+20, width: 150, height: 44))
        self.modeView.addSubview(self.lightNumText)
        self.lightNumText.backgroundColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
        self.lightNumText.layer.cornerRadius = 22
        self.lightNumText.text = "100"
        self.lightNumText.textColor = .black
        self.lightNumText.textAlignment = .center
        self.lightNumText.font = UIFont.boldSystemFont(ofSize: 16)
        self.lightNumText.keyboardType = .numberPad
    }
    
    @objc func modeBtnClick(_ sender:UIButton) {
        sender.isSelected = true
        self.setupTargetBtnStatus(true, sender)
        self.lightModeSelectBtn.isSelected = false
        self.setupTargetBtnStatus(false, self.lightModeSelectBtn)
        self.lightModeSelectBtn = sender
        
        self.lightColor = "0\(sender.tag+1)"
    }
    
    func setupTargetBtnStatus(_ status:Bool, _ sender:UIButton) {
        if status {
            sender.backgroundColor = .black
        } else {
            sender.backgroundColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1)
        }
    }
    
    func createNavSubViews(_ navView:UIView) {
        
        let titleL = UILabel(frame: CGRect(x: 0, y: statusHeight, width: screenWidth, height: 44))
        titleL.text = "光源设置"
        titleL.font = UIFont.boldSystemFont(ofSize: 18)
        titleL.textAlignment = .center
        navView.addSubview(titleL)
        
        let backBtn = UIButton(frame: CGRect(x: 10, y: statusHeight, width: 40, height: 40))
        backBtn.setImage(UIImage(named: "BackIcon"), for: .normal)
        navView.addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sureBtnClick() {
        let lightColorNum:String = self.lightNumText.text ?? "100"
        self.completeBlock?(self.lightSourceType, self.lightColor, lightColorNum)
        self.navigationController?.popViewController(animated: true)
    }

}
