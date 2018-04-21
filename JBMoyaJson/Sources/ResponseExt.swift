//
//  ResponseExt.swift
//  UnionPass
//
//  Created by 薛 靖博 on 2018/4/20.
//  Copyright © 2018年 薛 靖博. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Result

/// 响应结果处理协议
protocol DealRespose {
    /// 处理结果
    ///
    /// - Returns: 结果
    func deal() -> Result<Self, JBError>
}

extension ObservableType where E == Result<Response, MoyaError> {
    /// 绑定处理模型
    ///
    /// - Parameter type: 模型类型
    /// - Returns: 包含结果的观察者
    func bind<T: JBCodable & DealRespose>(with type: T.Type) -> Observable<Result<T, JBError>> {
        return flatMap { response -> Observable<Result<T, JBError>> in
            return Observable.just(response.mapModel(T.self))
        }
    }
}

extension Result where T == Response, Error == MoyaError {
    /// 处理结果
    ///
    /// - Parameter type: 模型类型
    /// - Returns: 结果
    func mapModel<E: JBCodable & DealRespose>(_ type: E.Type) -> Result<E, JBError> {
        switch self {
        case .success(let response):
            return response.mapModel(E.self)
        case .failure(let error):
            return Result<E, JBError>(error: JBError.net(error.localizedDescription))
        }
    }
}

extension Response {
    /// 处理响应
    ///
    /// - Parameter type: 模型类型
    /// - Returns: 结果
    func mapModel<E: JBCodable & DealRespose>(_ type: E.Type) -> Result<E, JBError> {
        return E.decode(data).analysis(ifSuccess: { (obj) -> Result<E, JBError> in
            return obj.deal()
        }, ifFailure: { (error) in
            return Result<E, JBError>(error: error)
        })
    }
}



