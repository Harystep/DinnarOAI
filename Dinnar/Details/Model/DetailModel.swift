//
//  DetailModel.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import Foundation
class DetailModel:BaseModel {
    var operatorName:String?
    var addTime:String?
    var image:UIImage?
    var productId:String?
    var group:[AreaModel] = []
    var photo:String = ""
    var result:String = ""
    var handleTime:String = ""
}

