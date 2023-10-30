////
////  ParameterEncoding.swift
////  Dinnar
////
////  Created by Lizheng Pang on 2023/6/24.
////
//
//import Foundation
//struct ParameterEncoding: ParameterEncoding {
//    
//    /// Configures how `Array` parameters are encoded.
//    ///
//    /// - brackets:        An empty set of square brackets is appended to the key for every value.
//    ///                    This is the default behavior.
//    /// - noBrackets:      No brackets are appended. The key is encoded as is.
//    enum ArrayEncoding {
//        case brackets, noBrackets
//
//        func encode(key: String) -> String {
//            switch self {
//            case .brackets:
//                return "\(key)[]"
//            case .noBrackets:
//                return key
//            }
//        }
//    }
//
//    /// Configures how `Bool` parameters are encoded.
//    ///
//    /// - numeric:         Encode `true` as `1` and `false` as `0`. This is the default behavior.
//    /// - literal:         Encode `true` and `false` as string literals.
//    enum BoolEncoding {
//        case numeric, literal
//
//        func encode(value: Bool) -> String {
//            switch self {
//            case .numeric:
//                return value ? "1" : "0"
//            case .literal:
//                return value ? "true" : "false"
//            }
//        }
//    }
//    
//    static let `default` = ParameterEncoding()
//    
//    /// The encoding to use for `Array` parameters.
//    private let arrayEncoding: ArrayEncoding
//
//    /// The encoding to use for `Bool` parameters.
//    private let boolEncoding: BoolEncoding
//    
////    private let authenticator: HMAC
//    
//    init() {
//        arrayEncoding = .noBrackets
//        boolEncoding = .literal
//        
//    }
//    
//    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//        var urlRequest = try urlRequest.asURLRequest()
//        
//        guard let url = urlRequest.url else {
//            throw AFError.parameterEncodingFailed(reason: .missingURL)
//        }
//        
//        guard var parameters = parameters else {
//            return urlRequest
//        }
//        
//        parameters["platform"] = "Apple"
//        
//        //body
//        do {
//            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
//
//            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
//                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            }
//
//            urlRequest.httpBody = data
//        } catch {
//            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
//        }
//        
//        //sign
//        let currentTime = UInt64((Date().timeIntervalSince1970 * 1000).rounded())
//        
//        //append url
//        var signParameters = [String: Any]()
//        // TODO: add token
//        if let token = KVService.getString(forKey: .token) {
//            signParameters["token"] = token
//        }
//        
//        if let code = KVService.getString(forKey: .code) {
//            let authenticator: HMAC
//            
//            do {
//                authenticator = try HMAC(key: code, variant: .sha256)
//            } catch  {
//                log.error(error)
//                fatalError("签名算法初始化失败!")
//            }
//            
//            let parameterString:String
//            if parameters.count > 0 {
//                parameterString = query(parameters) + "&time=\(currentTime)"
//            } else {
//                parameterString = "time=\(currentTime)"
//            }
//            guard let data = parameterString.data(using: .utf8) else {
//                throw AFError.parameterEncodingFailed(reason: .missingURL)
//            }
//            let authenticateBytes: [UInt8]
//            do {
//                 authenticateBytes = try authenticator.authenticate(data.kl.bytes)
//            } catch  {
//                log.error(error)
//                throw AFError.parameterEncodingFailed(reason: .missingURL)
//            }
//            guard let authenticateString = authenticateBytes.toBase64() else {
//                throw AFError.parameterEncodingFailed(reason: .missingURL)
//            }
//            
//            signParameters["sign"] = authenticateString
//        }
//        signParameters["time"] = currentTime
//        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !signParameters.isEmpty {
//            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(signParameters)
//            urlComponents.percentEncodedQuery = percentEncodedQuery
//            urlRequest.url = urlComponents.url
//        }
//        
//        return urlRequest
//    }
//    
//    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
//    ///
//    /// - parameter key:   The key of the query component.
//    /// - parameter value: The value of the query component.
//    ///
//    /// - returns: The percent-escaped, URL encoded query string components.
//    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
//        var components: [(String, String)] = []
//
//        if let dictionary = value as? [String: Any] {
//            if let jsonString = dictionary.jsonString() {
//                components.append((key, jsonString))
//            }
//        } else if let array = value as? [Any] {
//            if let jsonString = array.jsonString() {
//                components.append((key, jsonString))
//            }
//        } else if let value = value as? NSNumber {
//            if value.isBool {
//                components.append((escape(key), escape(boolEncoding.encode(value: value.boolValue))))
//            } else {
//                components.append((escape(key), escape("\(value)")))
//            }
//        } else if let bool = value as? Bool {
//            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
//        } else {
//            components.append((escape(key), escape("\(value)")))
//        }
//
//        return components
//    }
//
//    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
//    ///
//    /// RFC 3986 states that the following characters are "reserved" characters.
//    ///
//    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
//    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
//    ///
//    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
//    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
//    /// should be percent-escaped in the query string.
//    ///
//    /// - parameter string: The string to be percent-escaped.
//    ///
//    /// - returns: The percent-escaped string.
//    private func escape(_ string: String) -> String {
//        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
//        let subDelimitersToEncode = "!$&'()*+,;="
//
//        var allowedCharacterSet = CharacterSet.urlQueryAllowed
//        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
//
//        var escaped = ""
//
//        //==========================================================================================================
//        //
//        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
//        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
//        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
//        //  info, please refer to:
//        //
//        //      - https://github.com/Alamofire/Alamofire/issues/206
//        //
//        //==========================================================================================================
//
//        if #available(iOS 8.3, *) {
//            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
//        } else {
//            let batchSize = 50
//            var index = string.startIndex
//
//            while index != string.endIndex {
//                let startIndex = index
//                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
//                let range = startIndex..<endIndex
//
//                let substring = string[range]
//
//                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
//
//                index = endIndex
//            }
//        }
//
//        return escaped
//    }
//
//    private func query(_ parameters: [String: Any]) -> String {
//        var components: [(String, String)] = []
//
//        for key in parameters.keys.sorted(by: <) {
//            let value = parameters[key]!
//            components += queryComponents(fromKey: key, value: value)
//        }
//        return components.map { "\($0)=\($1)" }.joined(separator: "&")
//    }
//}
//
//// MARK: -
//
//extension NSNumber {
//    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
//}
