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
    
    @MainActor
    func testTimer() async {
        // this will be the clock used in feature reducer
        let clock = TestClock()
        
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            // dependency injection
            $0.continuousClock = clock
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        // ❌ An effect returned for this action is still running.
        //    It must complete before the end of the test. …
        //  because the TestStore forces you to assert on how your entire feature evolves over time, including effects
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        
        // add aseertion about timer behavior
//        await store.receive(\.timerTick, timeout: .seconds(2)) { // use key path for singling our from Action enum + explicit timeout checker
//            $0.count = 1
//            // ✅ Test Suite 'Selected tests' passed.
//            //        Executed 1 test, with 0 failures (0 unexpected) in 1.044 (1.046) seconds
//            //    or:
//            // ❌ Expected to receive an action, but received none after 0.1 seconds.
//        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    @MainActor
    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { dependency in
            dependency.numberFact.fetch = { "\($0) is a good number." }
        }
        
        // tap fact button + seeing the progress indicator
        // then the fact is fed back into the system
        await store.send(.factButtonTapped) {
            $0.isLoading = true
//            $0.fact = "???" // but at this point, how can you assert on this result?
            // we can not predict network result
        }
        
        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
