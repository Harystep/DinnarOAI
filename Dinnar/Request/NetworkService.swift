//
//  NetworkService.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/24.
//

import Foundation
import Foundation
import Moya
//import handyjson
struct NetworkService {

    private static let provider = defaultProvider()

    private static func defaultProvider() -> MoyaProvider<MultiTarget> {
        #if DEBUG
        return MoyaProvider<MultiTarget>(plugins:[KLNetworkLoggerPlugin()])
        #else
        return MoyaProvider<MultiTarget>()
        #endif
    }


    /// 请求数据(返回 jsonObject)
    /// - Parameters:
    ///   - target: api
    ///   - successCallback:  成功回调
    ///   - failureCallback: 失败回调
    @discardableResult static func request(
        target: TargetType,
        success successCallback: ((Any, Response) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?
        ) -> Cancellable {
        return provider.request(MultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes().filterBusinessError()
                    let jsonObject = try response.mapJSON()
                    successCallback?(jsonObject, response)
                }
                catch {
                    failureCallback?(error as! MoyaError)
                }
            case let .failure(error):
                failureCallback?(error)
            }
        }
    }


    /// 请求数据_没有业务错误过滤
    /// - Parameters:
    ///   - target: api
    ///   - successCallback:  成功回调
    ///   - failureCallback: 失败回调
    @discardableResult static func requestWithNoBusinessFilter(
        target: TargetType,
        success successCallback: ((Any, Response) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?
        ) -> Cancellable {
        return provider.request(MultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                do {
                    if let array = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: AnyObject] {//转化失败就返回
                         print(array)
                    }
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON()
                    successCallback?(jsonObject, response)
                }
                catch {
                    failureCallback?(error as! MoyaError)
                }
            case let .failure(error):
                failureCallback?(error)
            }
        }
    }

    /// 请求数据(返回序列化过的 model 或者 modelArray)
    /// - Parameters:
    ///   - target: api(必选参数)
    ///   - type: model 类型(必选参数)
    ///   - keyPath: 需要序列化的数据段的 key, 默认为 nil, 序列化全部 jsondata(可选参数)
    ///   - decoder: JSONDecoder, 默认为 default(可选参数)
    ///   - failsOnEmptyData:  空数据是否按失败处理, 默认为 true(可选参数)
    ///   - successCallback: 成功回调(可选参数)
    ///   - failureCallback: 失败回调(可选参数)
    @discardableResult static func requestAndMapObject<T: Decodable>(
        target: TargetType,
        _ type: T.Type,
        atKeyPath keyPath: String? = nil,
        using decoder: JSONDecoder = JSONDecoder(),
        failsOnEmptyData: Bool = true,
        success successCallback: ((T, Response) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?) -> Cancellable {

        return provider.request(MultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes().filterBusinessError()
                    let model = try response.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                    successCallback?(model, response)
                }
                catch {
//                    log.error(error)
                    failureCallback?(error as! MoyaError)
                }
            case let .failure(error):
                failureCallback?(error)
            }
        }

    }
    @discardableResult static func requestAMapObject<T: Decodable>(
        target: TargetType,
        _ type: T.Type,
        atKeyPath keyPath: String? = nil,
        using decoder: JSONDecoder = JSONDecoder(),
        failsOnEmptyData: Bool = true,
        success successCallback: ((T, Response) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?) -> Cancellable {

        return provider.request(MultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes().filterBusinessError()
                    let model = try response.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                    successCallback?(model, response)
                }
                catch {
//                    log.error(error)
                    failureCallback?(error as! MoyaError)
                }
            case let .failure(error):
                failureCallback?(error)
            }
        }

    }
}
