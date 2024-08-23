//
//  NumberFactClient.swift
//  SwiftUI-TCA-Study
//
//  Created by 박민서 on 8/23/24.
//

import ComposableArchitecture
import Foundation

struct NumberFactClient {
    // controlling dependency - model an interface
    // we prefer to use structs with mutable properties to represent the interface - just in TCA
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue: NumberFactClient = Self(fetch: { number in
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(number)")!)
        return String(decoding: data, as: UTF8.self)
    })
}

extension DependencyValues {
    // add computed property to DependencyValues
    // with getter, setter -> allows for @Dependency(\.numberFact)
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}
