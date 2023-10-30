//
//  AreaModel.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/18.
//

import Foundation
class AreaModel: BaseModel {
    var recordId:String = ""
    var type:String = ""
    var area:String = "0"
    var percentage:String = "0"
}
class AreaModel2:NSObject {
    @objc var recordId:String = ""
    @objc var type:String = ""
    @objc var area:String = "0"
    @objc var percentage:String = "0"
    func toModel()->AreaModel{
        let model = AreaModel.init()
        model.recordId = self.recordId
        model.type = self.type
        model.area = self.area
        model.percentage = self.percentage
        return model
    }
}
