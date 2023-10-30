//
//  ImageCell.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    var model:DetailModel?{
        didSet{
            if let model = model {
                if model.image != nil{
                    DispatchQueue.main.async {                        
                        self.imgView.image = model.image
                    }
                }else{
                    self.imgView.setImage(withUrlStr: model.photo)
                }
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(ges:)))
        self.imgView.addGestureRecognizer(tap)
        // Initialization code
    }
    @objc func tap(ges:UITapGestureRecognizer){
        let browser = YBImageBrowser()
        let data = YBIBImageData()
        data.projectiveView = imgView
        if let model = self.model{
            if let img = model.image {
                if let path = ImageTool.saveImg(image: img){
                    data.imagePath = path
                }
            }else{
                if let url  = URL.init(string: model.photo) {
                    data.imageURL = url
                }
            }
        }
        data.allowSaveToPhotoAlbum = false
        browser.dataSourceArray = [data]
        browser.currentPage = 0
        browser.defaultToolViewHandler?.topView.operationButton.isHidden = true
        browser.show()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
