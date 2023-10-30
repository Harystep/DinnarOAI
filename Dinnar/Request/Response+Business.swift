//
//  NetwokService.swift
//  kuailaizhibo
//
//  Created by devjia on 2019/11/15.
//  Copyright © 2019 Beijing good platform network Technology Co., Ltd. All rights reserved.
//

import Foundation
import Moya

extension Response {
    func filterBusinessError() throws -> Response {
        guard let jsonObject = try mapJSON() as? Dictionary<String, Any> else {
            throw MoyaError.jsonMapping(self)
        }
//        print(jsonObject)
        guard let code = jsonObject["code"] as? Int, let msg = jsonObject["msg"] as? String, let body = jsonObject["data"] else {
            throw MoyaError.underlying(BusinessError.invalidDataStructure, self)
        }
        if (code != 200) {
            if msg != "NO", msg != "OK"{
//                window.makeToast(msg, position: .center)
                if code == 1000000 {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: TUIKitNotification_TIMUserStatusListener), object: nil)
                }
            }
            throw MoyaError.underlying(BusinessError.business(code:code,msg:msg), self)
        }
        
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw MoyaError.jsonMapping(self)
            }
        }
        guard let businessData = try serializeToData(body) else {
            throw MoyaError.jsonMapping(self)
        }
        return Response(statusCode: statusCode, data: businessData, request: request, response: response)
    }
}

//{
//    args =     {
//    };
//    body =     {
//        code = dcb6356cd39a4ddf864257d2f05f3df1;
//        data =         {
//            cert = 0;
//            email = "<null>";
//            face = "<null>";
//            id = 0d2572054fbe4c9b9663303a5b662961;
//            name = "<null>";
//            nick = "<null>";
//            phone = 18511419351;
//            username = "<null>";
//        };
//        role =         (
//        );
//        token = 653b1486eaec15725d2e76b7abd5e919d8d73292aa66b0016c168f93ecada7d4373dcb1f8a72a85f7fbef23ec244c20d30ebbe39a89dde35908b9cb085b05ebcbd1f7e39e32664b55f850ec5456b0a0ed52c0ac1603fdf61c8d518b6c6fbdb31e6017b69e3b018dc600ed329e2ab2126;
//    };
//    code = 0;
//    leaf =     {
//    };
//    msg = OK;
//}

enum BusinessError: Swift.Error {
    case invalidDataStructure
    case business(code: Int, msg: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidDataStructure:
            return "数据结构异常"
        case .business(let code, let msg):
            return "业务失败! 错误码:" + "\(code)" + msg
        }
    }
}

//-1    请求执行失败
//0    请求执行成功
//10001    请求参数非法
//10002    请求参数为空
//10003    参数类型非法
//10004    数组个数过大
//10005    参数长度过大
//10006    参数低于下限
//10007    参数高于上限
//10008    数组设值非法
//10009    参数签名非法
//20001    请求票据无效
//30001    业务暂不支持
//30002    业务逻辑错误
//30003    你的操作非法
//40001    查询数据失败
//40002    数据存在错误
//50001    未知内部错误
//50002    请求网络繁忙


extension Response: ExtensionCompatible { }
extension ExtensionWrapper where Base: Response {
    
    /// Maps data received from the signal into a JSON object.
    ///
    /// - parameter failsOnEmptyData: A Boolean value determining
    /// whether the mapping should fail if the data is empty.
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: base.data, options: .allowFragments)
        } catch {
            if base.data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw MoyaError.jsonMapping(base)
        }
    }

    /// Maps data received from the signal into a String.
    ///
    /// - parameter atKeyPath: Optional key path at which to parse string.
    func mapString(atKeyPath keyPath: String? = nil) throws -> String {
        if let keyPath = keyPath {
            // Key path was provided, try to parse string at key path
            guard let jsonDictionary = try mapJSON() as? NSDictionary,
                let string = jsonDictionary.value(forKeyPath: keyPath) as? String else {
                    throw MoyaError.stringMapping(base)
            }
            return string
        } else {
            // Key path was not provided, parse entire response as string
            guard let string = String(data:base.data, encoding: .utf8) else {
                throw MoyaError.stringMapping(base)
            }
            return string
        }
    }

    /// Maps data received from the signal into a Decodable object.
    ///
    /// - parameter atKeyPath: Optional key path at which to parse object.
    /// - parameter using: A `JSONDecoder` instance which is used to decode data to an object.
    func map<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw MoyaError.jsonMapping(self.base)
            }
        }
        let jsonData: Data
        keyPathCheck: if let keyPath = keyPath {
            guard let jsonObject = (try mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
                if failsOnEmptyData {
                    throw MoyaError.jsonMapping(base)
                } else {
                    jsonData = base.data
                    break keyPathCheck
                }
            }

            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw MoyaError.jsonMapping(base)
                }
                do {
                    return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
                } catch let error {
                    throw MoyaError.objectMapping(error, base)
                }
            }
        } else {
            jsonData = base.data
        }
        do {
            if jsonData.count < 1 && !failsOnEmptyData {
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
                    return emptyDecodableValue
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
                    return emptyDecodableValue
                }
            }
            return try decoder.decode(D.self, from: jsonData)
        } catch let error {
            throw MoyaError.objectMapping(error, base)
        }
    }
}

private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}
