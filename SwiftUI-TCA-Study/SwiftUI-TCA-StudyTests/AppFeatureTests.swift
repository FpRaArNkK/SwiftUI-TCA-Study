//
//  AppFeatureTests.swift
//  SwiftUI-TCA-StudyTests
//
//  Created by 박민서 on 9/4/24.
//

import ComposableArchitecture
import XCTest

@testable import SwiftUI_TCA_Study

final class AppFeatureTests: XCTestCase {
    func testIncrementInFirstTab() async {
        let store = await TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
    }
}
