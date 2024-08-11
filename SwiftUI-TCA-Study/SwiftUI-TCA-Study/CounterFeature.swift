//
//  CounterFeature.swift
//  SwiftUI-TCA-Study
//
//  Created by 박민서 on 8/8/24.
//

import ComposableArchitecture
import Foundation

@Reducer // Reducer macro annotation
struct CounterFeature {
    // 0. Create State, Action, and Body to conform to Reducer.
    // 1. State - Defines the data states required by the feature.
    // 2. Action - Defines the actions that users can perform in the feature.
    // 3. Body - Contains the reducers that update States based on Actions.
    
    @ObservableState // Use this when the feature is to be observed by SwiftUI.
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    enum Action {
        // Name the Action based on what the user does in the UI.
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }
    
    enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        // body must be declared with Reduce reducer.
        // - One or more reducers can be composed in this body.
        // - List the reducers that you want to compose.
        Reduce { state, action in
            // state is provided as inout - can perform mutations directly.
            switch action {
                // Define the logic that updates states for each action.
                // In some cases, return effects to be executed externally.
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none // Must return an Effect.
                // Effect - Actions to be executed externally.
                // If nothing, return .none.
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                
                // TCA Seperates Side Effects. - not allowed here
                // This asynchronous call should be excuted as a side effect
                //                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)
                //                state.fact = String(decoding: data, as: UTF8.self)
                //                state.isLoading = false
                // 🛑 'async' call in a function that does not support concurrency
                // 🛑 Errors thrown from here are not handled
                
                
                // One way to construct an Effect is via using .run.
                // This provides you with an asynchronous context.
                return .run { [count = state.count] send in
                    // ✅ Do async work in here, and send actions back into the system.
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    
                    // state.fact = fact
                    // 🛑 Mutable capture of 'inout' parameter 'state' is not allowed in
                    //    concurrently-executing code
                    
                    // Send to another action with data after performing the asynchronous work
                    // Through this, you can feed the information from the effect back into reducer
                    await send(.factResponse(fact))
                    
                }
                
            case .factResponse(let fact):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            // Send this action every seconds
                            await send(.timerTick)
                        }
                    }
                    // Effect cancelation
                    // It can be cancelled by using .cancel(id:) effect.
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            }
        }
    }
}
