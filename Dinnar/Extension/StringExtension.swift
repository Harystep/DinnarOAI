//
//  StringExtension.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/28.
//

import Foundation

extension String {
  
    func tojson()-> Any?{
        if let data = self.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data)
        }
        return nil
    }
}

