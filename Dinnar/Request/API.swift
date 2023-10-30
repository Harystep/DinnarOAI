//
//  API.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/24.
//

import Foundation
import Moya

enum API {
    case login(userName: String,password:String)//登录
    case scanAddImages(img: UIImage,productId:String,result:String,operator:String,addTime:String,group:String)//登录
    case scanQuery(startTime:String,endTime:String,currentPage:Int,pageSize:Int)//登录
}
extension API: TargetType{
    var baseURL: URL {
        return URL(string:BaseUrl.url)!
    }
    var path: String {
        switch self {
        case .login(_,_):
            return "/user/login"
        case .scanAddImages(_,_,_,_,_,_):
            return "/scan/addImages"
        case .scanQuery(_,_,_,_):
            return "/scan/query"
        }
    }
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    var task: Task {
        switch self {
        case .login(let userName, let password):
            return .requestParameters(parameters: ["username":userName,"password":password], encoding: JSONEncoding.default)
        case .scanAddImages(let img,let productId,let result,let ope,let addTime,let group):
            var formDatas = [MultipartFormData]()
            let imageData = img.jpegData(compressionQuality: 0.8)
            let fileName = UUID().uuidString + ".jpeg"
                        let formData = MultipartFormData(provider: .data(imageData!), name: "file", fileName: fileName, mimeType: "image/jpeg")
                            formDatas.append(formData)
            return .uploadCompositeMultipart(formDatas, urlParameters: ["productId":productId,"result":result,"operator":ope,"addTime":addTime,"group":group])
        case .scanQuery(let startTime, let endTime,let currentPage,let pageSize):
            return .requestParameters(parameters: ["startTime":startTime,"endTime":endTime,"currentPage":currentPage,"pageSize":pageSize], encoding: JSONEncoding.default)
            
        }
    }
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        var para:[String:String] =  ["Content-Type":"application/json"]
        switch self {
        case .login(_,_):
            break
        default:
            if let token = DataTool.getToken(){
                para["Authorization"] = token
            }
            break
            
        }
        print(para)
        return para
    }
        
    
    
}
