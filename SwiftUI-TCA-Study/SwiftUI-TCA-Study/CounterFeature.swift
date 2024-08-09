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
    struct State {
        var count = 0
        var fact: String?
        var isLoading = false
    }
    
    enum Action {
        // Name the Action based on what the user does in the UI.
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
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
                // 🛑 'async' call in a function that does not support concurrency
                // 🛑 Errors thrown from here are not handled
                
//                state.fact = String(decoding: data, as: UTF8.self)
                state.isLoading = false
                return .none
            }
        }
    }
}
