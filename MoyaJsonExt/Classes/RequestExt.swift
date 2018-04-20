//
//  RequestExt.swift
//  UnionPass
//
//  Created by 薛 靖博 on 2018/4/19.
//  Copyright © 2018年 薛 靖博. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Result

extension Reactive where Base: MoyaProviderType {
    /// 对Moya网络请求扩展
    ///
    /// - Parameters:
    ///   - token: 接口名称
    ///   - callbackQueue: 回调队列
    /// - Returns: 发出的信号
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Result<Response, MoyaError>> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                single(.success(result))
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}

