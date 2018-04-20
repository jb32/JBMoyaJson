//
//  JSONExt.swift
//  UnionPass
//
//  Created by 薛 靖博 on 2018/4/19.
//  Copyright © 2018年 薛 靖博. All rights reserved.
//

import Foundation
import Result

/// 异常与错误处理
///
/// - encode: 解码错误
/// - net: 网络错误
/// - result: 服务器结果失败处理
enum JBError: Error {
    case encode(String)
    case net(String)
    case result(String)
    
    var errorMsg: String {
        switch self {
        case .encode(let msg), .net(let msg), .result(let msg):
            return msg
        }
    }
}

/// 编码、解码
protocol JBCodable: Codable {
    func encode() -> Result<Data, JBError>
    static func decode(_ data: Data) -> Result<Self, JBError>
}

extension JBCodable {
    
    func encode() -> Result<Data, JBError> {
        do {
            let result = try JSONEncoder().encode(self)
            return Result(value: result)
        } catch let error {
            return Result(error: JBError.encode(error.localizedDescription))
        }
    }
    
    static func decode(_ data: Data) -> Result<Self, JBError> {
        do {
            let object = try JSONDecoder().decode(Self.self, from: data)
            return Result<Self, JBError>(value: object)
        } catch {
            return Result<Self, JBError>(error: JBError.encode(error.localizedDescription))
        }
    }
    
    static func decode<T: Collection>(_ obj: T) -> Result<Self, JBError> {
        do {
            let data = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            let object = try JSONDecoder().decode(Self.self, from: data)
            return Result<Self, JBError>(value: object)
        } catch {
            return Result<Self, JBError>(error: JBError.encode(error.localizedDescription))
        }
    }
}

extension Result where T == Data, Error == JBError {
    /// 转化为字典或者数组
    ///
    /// - Returns: <#return value description#>
    func jsonObj() -> Result<Any, JBError> {
        return analysis(ifSuccess: {
            do {
                let result = try JSONSerialization.jsonObject(with: $0, options: .mutableContainers)
                return Result<Any, JBError>(value: result)
            } catch let err {
                return Result<Any, JBError>(error: JBError.encode(err.localizedDescription))
            }
        }, ifFailure: {
            return Result<Any, JBError>(error: $0)
        })
    }
    
    /// 转化为json字符串
    ///
    /// - Returns: <#return value description#>
    func jsonString() -> Result<String, JBError> {
        return analysis(ifSuccess: {
            if let json = String(data: $0, encoding: .utf8) {
                return Result<String, JBError>(value: json)
            } else {
                return Result<String, JBError>(error: JBError.encode(#function + "[\(#line)]" + " failtrue"))
            }
        }, ifFailure: {
            return Result<String, JBError>(error: $0)
        })
    }
}








