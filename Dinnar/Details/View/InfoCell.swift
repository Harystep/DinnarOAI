//
//  InfoCell.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit

class InfoCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var handleTimeL: UILabel!
    var model:DetailModel?{
        didSet{
            timeLabel.text = model?.addTime ?? ""
            productLabel.text = "产品ID：\(model?.productId ?? "")"
            handleTimeL.text = "\(model?.handleTime ?? "")ms"
            if model?.result == "1" {
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
