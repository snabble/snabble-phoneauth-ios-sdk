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
         doBefore handler: () -> Void
      ) -> AnyPublisher<Upstream.Output, Upstream.Failure> {

      upstream
         .map { output -> Result<Upstream.Output, Upstream.Failure> in .success(output) }
         .catch { error -> AnyPublisher<Result<Upstream.Output, Upstream.Failure>, Upstream.Failure> in
            if predicate(error) {
               return Fail(error: error).eraseToAnyPublisher()
            } else {
               return Just(.failure(error))
                  .setFailureType(to: Upstream.Failure.self)
                  .eraseToAnyPublisher()
            }
         }
         .retry(retries)
         .flatMap { result in result.publisher }
         .eraseToAnyPublisher()
   }

    func retry(_ retries: Int, when predicate: @escaping (Failure) -> Bool, doBefore handler: () -> Void) -> AnyPublisher<Output, Failure> {
      return retryOnly(upstream: self, retries: retries, when: predicate, doBefore: handler)
   }
}
