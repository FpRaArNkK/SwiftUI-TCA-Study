//
//  CounterFeatureTests.swift
//  SwiftUI-TCA-StudyTests
//
//  Created by 박민서 on 8/12/24.
//

import ComposableArchitecture
import XCTest

@testable import SwiftUI_TCA_Study


final class CounterFeatureTests: XCTestCase {
    @MainActor // MainActor shouldn't be used with a non-isolated class - Swift 6
    func testCounter() async { // TCA testing tool use asynchrony.
        // Create a TestStore in the same way you create a Store.
        let store = TestStore(initialState: CounterFeature.State()) { // TestStore requires State to conform to the Equatable protocol - for assertions.
            CounterFeature()
        }
        
        // Start sending actions into the TestStore.
        // You have to describe the State after the Action is sent.
        await store.send(.incrementButtonTapped) {
            // You have to provide assertion
            // $0 is mutable version of the State before the action is sent - change
            // Mutate $0 so that it equals the state after the action is sent - change
            $0.count = 1
        }

        await store.send(.decrementButtonTapped) {
            // Prefer to use 'absolute' mutation like `= 0`.
            // `= 0`, absolute assetion the knows exact state
            // `+= 1`, relative assertion merely knows what transformation was applied to the state
            $0.count = 0
        }
    }
}
