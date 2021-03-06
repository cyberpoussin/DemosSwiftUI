//
//  AnyEncodable.swift
//  NewFlowerApp
//
//  Created by Admin on 17/03/2021.
//

import Foundation

struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
