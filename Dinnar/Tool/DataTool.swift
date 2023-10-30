//
//  DataTool.swift
//  MLModelTest
//
//  Created by Lizheng Pang on 2023/5/16.
//

import Foundation
class DataTool {
    ///读取CSV转Array
    static func readDataFromCSVToArray(fileName:String)-> [String]?{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "csv")
            else {
            return nil;
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            var result: [String] = []
            contents = contents.replacingOccurrences(of: "\r", with: "\n")
            contents = contents.replacingOccurrences(of: "\n\n", with: "\n")
            let rows = contents.components(separatedBy: "\n")
            for row in rows {
                result.append(row)
            }
            return result
        } catch {
            return nil
        }
    }
    ///转模型m5d8_HSG  m5d8_HSGOutput   m10d17_swift_v2Output  swift_1026Output  swift_1027_2  best
//    static func detectModelArray(from detect:m10d17_swift_v2Output,names:[String])->[DetectModel]{
    static func detectModelArray(from detect:bestOutput,names:[String])->[DetectModel]{
        
        var models:[DetectModel] = []
        ///解析位置信息
        let coordinates = detect.coordinates
        let shape  = coordinates.shape
        let rows = shape[0].intValue
        let columns = shape[1].intValue
        for row in 0..<rows {
            var centerX:Double = 0
            var centerY:Double = 0
            var width:Double = 0
            var Height:Double = 0
            for column in 0..<columns {
                let i = row * columns + column
                switch column {
                case 0:
                    centerX = Double(truncating: coordinates[i])
                    
                case 1:
                    centerY = Double(truncating: coordinates[i])
                    
                case 2:
                    width = Double(truncating: coordinates[i])
                    
                case 3:
                    Height = Double(truncating: coordinates[i])
                    
                default:
                    break
                }
            }
            let rect = CGRect.init(x: centerX, y: centerY, width: width, height: Height)
//            print("rect----->\(rect)")
            let model = DetectModel.init(rect: rect)
            models.append(model)
        }
//        print("count--->\(models.count)")
        ///解析可信度最大值的标签
        let confidence = detect.confidence
        let conShape  = confidence.shape
        let conRows = conShape[0].intValue
        let conColumns = conShape[1].intValue
        var modelArray:[DetectModel] = []
        for row in 0..<conRows {
            if row < models.count {
                let model = models[row]
                var name = ""
                var max:Double = 0
                for column in 0..<conColumns {
                    let i = row * conColumns + column
                    let value = Double(truncating: confidence[i])
                    if value > max {
                        max = value
                        name = names[column]
                    }
                }
                model.confidence = max
                model.labelName  = name
                modelArray.append(model)
                if !name.isEmpty{
                }
            }
        }
//        print("count2---->\(modelArray.count)")
        return modelArray
    }
    
    static func saveToken(token:String?,userName:String?){
        UserDefaults.standard.setValue(token, forKey: "token")
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.synchronize()
    }
    static func getToken()->String?{
        return UserDefaults.standard.string(forKey: "token")
    }
    static func getUserName()->String?{
        return UserDefaults.standard.string(forKey: "userName")
    }
    static func logOut(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.rootViewController = LoginViewController.initWithNib()
        appdelegate.window?.makeKeyAndVisible()
        self.saveToken(token: nil, userName: nil)
    }
    
    static func isiPhoneXScreen() -> Bool {
        let isX = UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
            return isX
        }
}
