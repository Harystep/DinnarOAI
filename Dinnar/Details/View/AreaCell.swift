//
//  AreaCell.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit

class AreaCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    var model:AreaModel?{
        didSet{
            nameLabel.text = model?.type;
            areaLabel.text = "\(model?.area ?? "0")"
            rateLabel.text = "\(model?.percentage ?? "0")"
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
