//
//  Publisher+RetryWhenDoBefore.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-27.
//

import Foundation
import Combine

extension Publisher {
    func retryOnly<Upstream: Publisher>(
        upstream: Upstream,
        retries: Int,
        when predicate: @escaping (Upstream.Failure) -> Bool,
        doBefore handler: @escaping () -> Void
    ) -> AnyPublisher<Upstream.Output, Upstream.Failure> {

        upstream
            .map { output -> Result<Upstream.Output, Upstream.Failure> in .success(output) }
            .catch { error -> AnyPublisher<Result<Upstream.Output, Upstream.Failure>, Upstream.Failure> in
                if predicate(error) {
                    handler()
                    return Fail(error: error).eraseToAnyPublisher()
                } else {
                    return Just(.failure(error))
                        .setFailureType(to: Upstream.Failure.self)
                        .eraseToAnyPublisher()
                }
            }
            .retry(retries)
            .flatMap { result in
                result.publisher
            }
            .eraseToAnyPublisher()
    }

    func retry(_ retries: Int, when predicate: @escaping (Failure) -> Bool, doBefore handler: @escaping () -> Void) -> AnyPublisher<Output, Failure> {
      return retryOnly(upstream: self, retries: retries, when: predicate, doBefore: handler)
   }
}

extension Publishers {
    struct RetryIf<P: Publisher>: Publisher {
        typealias Output = P.Output
        typealias Failure = P.Failure

        let publisher: P
        let times: Int
        let condition: (P.Failure) -> Bool

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            guard times > 0 else {
                return publisher.receive(subscriber: subscriber)
            }

            publisher.catch { (error: P.Failure) -> AnyPublisher<Output, Failure> in
                if condition(error)  {
                    return RetryIf(publisher: publisher, times: times - 1, condition: condition).eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }.receive(subscriber: subscriber)
        }
    }
}

extension Publisher {
    func retry(times: Int, if condition: @escaping (Failure) -> Bool) -> Publishers.RetryIf<Self> {
        Publishers.RetryIf(publisher: self, times: times, condition: condition)
    }
}
