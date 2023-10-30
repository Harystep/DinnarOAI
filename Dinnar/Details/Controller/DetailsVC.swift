//
//  DetailsVC.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit
import HandyJSON
enum DetailsVCType {
    case details
    case result
}
class DetailsVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var con: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    var point:NSString = ""
    var model:DetailModel!
    var vcType:DetailsVCType = .result
    var selectType:AlgorithmType = .detect
    var autoType:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()        
        creatUI()
        
        if self.autoType {            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.upLoad()
            }
        }
    }    
    
    func creatUI(){
        
        if vcType == .details{
            con.constant = 0
            self.titleLabel.text = "详情"
        }else{
            con.constant = 60
        }
        self.navView.addShadow(shadowColor: UIColor.black, shadowOpacity: 0.2, shadowRadius: 2, shadowOffset: CGSize.init(width: 0, height: 4))
        tableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.register(UINib.init(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        tableView.register(UINib.init(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "InfoCell")
        tableView.register(UINib.init(nibName: "AreaCell", bundle: nil), forCellReuseIdentifier: "AreaCell")
        tableView.register(UINib.init(nibName: "AreaHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AreaHeaderView")
        tableView.register(UINib.init(nibName: "AreafooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AreafooterView")
        
    }
    @IBAction func backBtnClick(){
        self.navigationController?.popToRootViewController(animated: true)
//        self.dismiss(animated: true)
    }
    @IBAction func sureBtnClick(){
        upLoad()
    }
    
    func dateToStr(date:Date) -> String{
        let dformatter = DateFormatter()
        // 为日期格式器设置格式字符串
        dformatter.dateFormat = "yyyy年MM月dd日 "
        // 使用日期格式器格式化日期、时间
        let datestr = dformatter.string(from: date)
        return datestr
    }
    func upLoad(){
        guard let img = model.image else {
            return
        }
        guard let name = DataTool.getUserName(),let productId = model.productId,let addTime = model.addTime else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        var group:String = "[]"
        if let jsonStr = model.group.toJSONString(){
            group = jsonStr
            print(group)
        }
        
        NetworkService.requestWithNoBusinessFilter(target: API.scanAddImages(img: img, productId: productId, result: model.result, operator: name, addTime: addTime,group:group)) { [self] (dict, response) in
            print(dict)
            hud.hide(animated: true)
            guard let dic = dict as? [String:Any],let msg = dic["msg"] as? String,let code = dic["code"] as? Int else {
                self.showToast("上传失败")
                return
            }
            self.showToast(msg)
            if code == 200 {
                let msg:NSString
                print("point--->\(self.point)")
                if self.model.group.count == 0 {
                    msg = "\(self.model.productId!)_OK_\(self.point)" as NSString
                } else {
                    msg = "\(self.model.productId!)_NG_\(self.point)" as NSString
                }
                print("msg---->\(msg)")
                SerialGATT.shareInstance()?.turnOffTheLight()
//                self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kSendClientDataKey"), object: msg)
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }else{
                if code == 401{
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.window?.rootViewController = LoginViewController.initWithNib()
                    appdelegate.window?.makeKeyAndVisible()
                }
            }
            
            
        } failure: { (error) in
            hud.hide(animated: true)
            self.showToast("登录失败")
        }
        
    }
}

extension DetailsVC:UITableViewDelegate,UITableViewDataSource{
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if  section == 0 {
//            return 0.001
//
//        }else{
//            return 1
//        }
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0{
//            return nil
//        }else{
//            let header =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "AreafooterView")
//            return header
//        }
//    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 1 {
            return 40
            
        }else{
            return 0.001
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let header =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "AreaHeaderView")
            return header
        }else{
            return nil
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if model.group.count > 0{
            return 2;
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let row = indexPath.row
            if row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
                cell.nameLabel.text = model.operatorName
                return cell
            }else if row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
                cell.model = model
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
                cell.model = self.model
                return cell
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell") as! AreaCell
            if let areas = model?.group{
                cell.model = areas[indexPath.row]
            }
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3;
        }else{
            return model.group.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let row = indexPath.row
            if row == 0{
                return 60
            }else if row == 1{
                return view.frame.width - 20
            }else{
                return 95
            }
            
        }else{
            return 40
        }
    }
    
}
