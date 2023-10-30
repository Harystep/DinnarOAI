//
//  DatePickerView.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit
protocol DatePickerViewDelegate:NSObjectProtocol {
    func selectDate(date:Date)
    // protocol definition goes here
}
class DatePickerView: UIView {
    @IBOutlet weak var con: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate:DatePickerViewDelegate?
    
    static func initWith(cuttrntDate:Date) ->DatePickerView{
        let view = Bundle.main.loadNibNamed("DatePickerView", owner: nil, options: nil)?.first! as! DatePickerView
        view.datePicker.date = cuttrntDate
        view.datePicker.maximumDate = Date()
        view.datePicker.locale = Locale.init(identifier: "zh_CN")
        return view
    }
    @IBAction func sureBtnClick(){
        UIView.animate(withDuration: 0.3) {
            self.con.constant = -300
            self.layoutIfNeeded()
            self.alpha = 0
        } completion: { (finishe) in
            self.removeFromSuperview()
        }

        delegate?.selectDate(date: datePicker.date)
    }
    func showInView(view:UIView){
        let window = ViewTool.currentWindow()
        self.frame = window?.frame ?? view.frame
        view.window?.addSubview(self)
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.con.constant = 0
            self.layoutIfNeeded()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
