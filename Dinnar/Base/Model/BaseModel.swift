//
//  BaseModel.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/20.
//

import Foundation
import HandyJSON
class BaseModel:HandyJSON {
    required init() {}
    static func initWith(dict:[String: Any]?, designatedPath: String? = nil) -> Self?{
        
        return deserialize(from: dict, designatedPath: designatedPath)
    }
    static func fromJson(_ json: String?, path: String? = nil) -> Self? {
        self.deserialize(from: json,designatedPath: path)
    }
//    static func fromDict(_ dict: Dictionary<String, Any>) -> Self? {
//        return self.deserialize(from: dict)
//    }
    static func fromDict(_ dict: NSDictionary) -> Self? {
        return self.deserialize(from: dict)
    }
//    static func fromDictToArray(_ dict: Array<Any>) -> [self]? {
//        return self.deserialize(from: dict) as? [self]
//    }
}
class PageDataModel<T:BaseModel>: BaseModel {
    var records:[T] = []
    var current:Int = 0
    var pages:Int = 0
    var size:Int = 0
    var total:Int = 0
}
