//
//  CounterFeature.swift
//  SwiftUI-TCA-Study
//
//  Created by 박민서 on 8/8/24.
//

import ComposableArchitecture

@Reducer // Reducer macro annotation
struct CounterFeature {
    // 0. Create State, Action, and Body to conform to Reducer.
    // 1. State - Defines the data states required by the feature.
    // 2. Action - Defines the actions that users can perform in the feature.
    // 3. Body - Contains the reducers that update States based on Actions.
    
    @ObservableState // Use this when the feature is to be observed by SwiftUI.
    struct State {
        var count = 0
    }
    
    enum Action {
        // Name the Action based on what the user does in the UI.
        case decrementButtonTapped
        case incrementButtonTapped
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
                return .none // Must return an Effect.
                // Effect - Actions to be executed externally.
                // If nothing, return .none.
            case .incrementButtonTapped:
                state.count += 1
                return .none
            }
        }
    }
}
