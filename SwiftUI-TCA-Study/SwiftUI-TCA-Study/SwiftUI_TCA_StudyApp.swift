//
//  SwiftUI_TCA_StudyApp.swift
//  SwiftUI-TCA-Study
//
//  Created by 박민서 on 8/8/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct SwiftUI_TCA_StudyApp: App {
    // The store can be held as a static variable.
//    static let store = Store(initialState: CounterFeature.State()) {
//        CounterFeature()
//    }
    
    var body: some Scene {
        WindowGroup {
            // Change the entry point by providing a store.
//            CounterView(store: SwiftUI_TCA_StudyApp.store)
            
            // For most apps, it's sufficient to create the store directly.
            CounterView(store: Store(initialState: CounterFeature.State()) {
                CounterFeature()
                    ._printChanges() // Reducers have their own debug print function.
            })
        }
    }
}
