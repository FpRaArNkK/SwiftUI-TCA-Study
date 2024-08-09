//
//  CounterView.swift
//  SwiftUI-TCA-Study
//
//  Created by 박민서 on 8/9/24.
//

import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    // Create a Store in the View where you want to use the reducer.
    // It can process actions to update the state, execute effects, and feed data.
    // Observation of the data in the Store happens automatically with the @ObservableState() macro.
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            // You can read properties of state directly from the store.
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Button("-") {
                    // You can send actions to the store via send(_:).
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    CounterView(
        // You need to construct StoreOf<Feature>.
        // Provide the initial state that the feature begins in.
        store: Store(initialState: CounterFeature.State()) {
            // Specify the reducer powering the feature.
            // You can run the preview with different reducers to alter how it executes.
            CounterFeature()
        }
    )
}
