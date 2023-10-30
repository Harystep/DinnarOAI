//
//  DetectModel.swift
//  MLModelTest
//
//  Created by Lizheng Pang on 2023/5/17.
//

import Foundation
class DetectModel {
    var rect:CGRect
    var labelName:String
    var confidence:Double
    init(rect:CGRect,labelName:String = "",confidence:Double = 0) {
        self.rect = rect
        self.labelName = labelName
        self.confidence = confidence
        
    }
}
