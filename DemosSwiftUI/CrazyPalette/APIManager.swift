//
//  APIPalett.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import SwiftUI
import Combine

protocol APIManager {
    var session: URLSession { get }
    func request<T: Decodable>(with: RequestBuilder) -> AnyPublisher<T?, Never>
    func request(with: RequestBuilder) -> AnyPublisher<Data?, Never>

}


protocol RequestBuilder {
    func build() -> URLRequest?
}


extension APIManager {
    func request<T: Decodable>(with requestBuilder: RequestBuilder) -> AnyPublisher<T?, Never> {
        guard let request = requestBuilder.build() else { return Just(nil).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: request)
            .map { response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            .decode(type: T?.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<T?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func request(with requestBuilder: RequestBuilder) -> AnyPublisher<Data?, Never> {
        guard let request = requestBuilder.build() else { return Just(nil).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: request)
            .map { response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            .catch { error -> AnyPublisher<Data?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

class APISession: APIManager {
    var session: URLSession = URLSession.shared
}

