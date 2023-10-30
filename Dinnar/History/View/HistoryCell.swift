//
//  HistoryCell.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var gbView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    var model:DetailModel?{
        didSet{
            if let model = model{
                timeLabel.text = model.addTime
                self.idLabel.text = "产品ID：\(model.productId ?? "")"
                self.nameLabel.text = "操作人员：\(model.operatorName ?? "")"
                self.imgView.setImage(withUrlStr: model.photo)
                if model.result == "1" {
                    resultLabel.text = "OK"
                    resultLabel.textColor = okTextColor
                    resultLabel.backgroundColor = okGgColor
                }else{
                    resultLabel.text = "NG"
                    resultLabel.textColor = ngTextColor
                    resultLabel.backgroundColor = ngGgColor
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        creatUI()
        // Initialization code
    }
    func creatUI(){
        self.gbView.layer.cornerRadius = 10
        self.gbView.layer.borderColor = UIColor.black.cgColor
        self.gbView.layer.borderWidth = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
