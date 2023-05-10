//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

private extension URLResponse {
    func verify(with data: Data) throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw HTTPError.unknownResponse(self)
        }
        guard httpResponse.httpStatusCode.responseType == .success else {
            throw HTTPError.invalidResponse(httpResponse.httpStatusCode)
        }
    }
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func tryVerifyResponse() -> AnyPublisher<Output, Swift.Error> {
        tryMap { (data, response) throws -> Output in
            try response.verify(with: data)
            return (data, response)
        }
        .eraseToAnyPublisher()
    }
}

extension URLSession {
    func dataTaskPublisher<Response: Decodable>(
        for endpoint: Endpoint<Response>
    ) -> AnyPublisher<Response, Swift.Error> {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.urlRequest()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return dataTaskPublisher(for: urlRequest)
            .tryVerifyResponse()
            .map(\.data)
            .tryMap { data in
                do {
                    return try endpoint.jsonDecoder.decode(Response.self, from: data)
                } catch {
                    if case DecodingError.dataCorrupted(_) = error, data.isEmpty {
                        guard let response = NoContent() as? Response else {
                            throw error
                        }
                        return response
                    }
                    throw error
                }
            }
            .eraseToAnyPublisher()
    }
}
