//
//  UIImageViewExt.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/25.
//

import Foundation
import Kingfisher
extension UIImageView{
    func setImage(withUrlStr urlStr:String?,placeholder: UIImage? = nil,complate:(() -> Void)? = nil){
        if let urlStr = urlStr {
            self.sd_setImage(with: URL.init(string: urlStr), placeholderImage: placeholder) { (img, error, cacheType, url) in
                complate?()
            }
        }else{
            complate?()
        }
    }
//    func setImageNoScale(withUrlStr urlStr:String?,placeholder: UIImage? = nil,complate:((_ img:UIImage?) -> Void)? = nil){
//        if let urlStr = urlStr {
//
//        }
//    }
    func loadImage(withUrlStr urlStr:String,complate:@escaping ((_ success:Bool)->Void)){
        if let url = URL.init(string: urlStr){
            ImageDownloader.default.downloadImage(with: url, options: nil, completionHandler:  { [weak self](result) in
                switch(result) {
                case .success(let data):
                    self?.image = data.image
                    complate(true)
                default:
                    complate(false)
                }
            })
        }else{
             complate(false)
        }
    }
    
    func setImgCornerRadius(cornerRadius:CGFloat){
        //1.建立上下文
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        UIRectFill(self.bounds)
        //2.创建椭圆path,宽、高一致返回的就是圆形路径
        let path = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: cornerRadius)
        //裁切
        path.addClip()
        //3.绘制图像
        self.draw(self.bounds)
        //4.获取绘制的图像
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        //5关闭上下文
        UIGraphicsEndImageContext()
    }
}
