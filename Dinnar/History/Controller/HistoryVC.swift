//
//  HistoryVC.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/16.
//

import UIKit
enum DateType {
    case day
    case month
}
class HistoryVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var dayBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    var datas:[DetailModel] = []
    var date = Date()
    var dateType:DateType = .day
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        creatUI()
        
        // Do any additional setup after loading the view.
    }
    func creatUI(){
        self.navView.addShadow(shadowColor: UIColor.black, shadowOpacity: 0.2, shadowRadius: 2, shadowOffset: CGSize.init(width: 0, height: 4))
        tableView.register(UINib.init(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        refreshUI()
        dateBtn.setTitle(dateToStr(date: date), for: .normal)
        tableView.addRefreshHeader { [weak self] in
            self?.request(page: 1)
        }
        tableView.addRefreshFooter { [weak self] in
            self?.request(page: self?.page ?? 1)
        }
        tableView.mj_header?.beginRefreshing()
    }
    func refreshUI(){
        if dateType == .day{
            dayBtn.backgroundColor = .black
            dayBtn.setTitleColor(.white, for: .normal)
            monthBtn.backgroundColor = dateBtn.superview?.backgroundColor
            monthBtn.setTitleColor(.black, for: .normal)
        }else{
            monthBtn.backgroundColor = .black
            monthBtn.setTitleColor(.white, for: .normal)
            dayBtn.backgroundColor = dateBtn.superview?.backgroundColor
            dayBtn.setTitleColor(.black, for: .normal)
        }
    }
    @IBAction func backBtnClick(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func dateBtnClick(){
        let datePickeView = DatePickerView.initWith(cuttrntDate: Date())
        datePickeView.delegate = self
        datePickeView.showInView(view: view)
    }
    @IBAction func dayOrMonthBtnClick(btn:UIButton){
        if btn == dayBtn {
            dateType = .day
        }else{
            dateType = .month
        }
        refreshUI()
        self.request(page: 1, showHud: true)
    }
    
    func dateToStr(date:Date) -> String{
        let dformatter = DateFormatter()
        // 为日期格式器设置格式字符串
        dformatter.dateFormat = "yyyy年MM月dd日"
        // 使用日期格式器格式化日期、时间
        let datestr = dformatter.string(from: date)
        return datestr
    }
    
    func request(page:Int,showHud:Bool = false){
        var startTime = ""
        var endTime = ""
        if self.dateType == .day {
            let time = DateTool.dayStartAndEnd(date: self.date)
            startTime = time.startTime
            endTime = time.endTime
        }else{
            let time = DateTool.monthStartAndEnd(date: self.date)
            startTime = time.startTime
            endTime = time.endTime
        }
        if showHud {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.removeFromSuperViewOnHide = true
        }
        NetworkService.requestWithNoBusinessFilter(target:API.scanQuery(startTime: startTime, endTime: endTime, currentPage: page, pageSize: 10)) { (dict, res) in
            self.tableView.endRefresh()
            MBProgressHUD.hide(for: self.view, animated: true)
            guard let dic = dict as? [String:Any],let msg = dic["msg"] as? String ,let code = dic["code"] as? Int else {
                self.showToast("请求失败")
                return
            }
            if code != 200{
                if code == 401{
                    self.showToast(msg)
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.window?.rootViewController = LoginViewController.initWithNib()
                    appdelegate.window?.makeKeyAndVisible()
                }
                return
            }
            if let model = PageDataModel<DetailModel>.initWith(dict: dic, designatedPath: "data"){
                if page == 1{
                    self.datas.removeAll()
                }
                self.datas.append(contentsOf:model.records)
                self.tableView.reloadData()
                self.page = page + 1
                if model.current == model.pages || model.pages == 0{
                    self.tableView.endLoadWithNoMoreData()
                }
            }else{
                self.showToast("请求失败")
            }
            
        } failure: { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.showText("请求失败")
            self.tableView.endRefresh()
        }
    }
}
extension HistoryVC:DatePickerViewDelegate{
    func selectDate(date: Date) {
        self.date = date
        dateBtn.setTitle(dateToStr(date: date), for: .normal)
        self.request(page: 1, showHud: true)
    }
}
extension HistoryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        cell.model = datas[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  130.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = datas[indexPath.row]
        let vc = DetailsVC.init()
        vc.model = model
        vc.vcType = .details
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
