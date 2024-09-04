---
date: ""
tags:
  - TCA
  - Study
---
## Section 1 - Adding a tab view
---
TabView를 추가해보며 Scope를 체험해보자
### Section 1 - Example.swift
- 주석 필요 없음
	```swift
	//
	//  AppFeature.swift
	//  SwiftUI-TCA-Study
	//
	//  Created by 박민서 on 9/4/24.
	//
	
	import ComposableArchitecture
	import SwiftUI
	
	struct AppView: View {
	    let store1: StoreOf<CounterFeature>
	    let store2: StoreOf<CounterFeature>
	    
	    var body: some View {
	        TabView {
	            CounterView(store: store1)
	                .tabItem {
	                    Text("Counter 1")
	                }
	            
	            CounterView(store: store2)
	                .tabItem {
	                    Text("Counter 2")
	                }
	        }
	    }
	}
	```
해당 코드는 예시이지만 이상적이지 않은 예시이다.
지금의 경우, Store가 2개로 따로따로 관리해야하는 상황이다. 
TCA에서는 여러 개의 독립된 Store가 아닌 하나의 Store에서 기능을 함께 구성하고 View를 제공하는 것을 선호한다.
일단 넘어가보자

## Section 2 - Composing reducers
---
여러 개의 독립된 Store를 가진 이상적이지 않은 환경을, reducer 단계에서 고쳐가보자.
### Section 2 - AppFeature.swift
- 주석 필요 없음
	```swift
	//
	//  AppFeature.swift
	//  SwiftUI-TCA-Study
	//
	//  Created by 박민서 on 9/4/24.
	//
	
	import ComposableArchitecture
	import SwiftUI
	
	@Reducer
	struct AppFeature {
	    struct State: Equatable {
	        var tab1 = CounterFeature.State()
	        var tab2 = CounterFeature.State()
	    }
	    
	    enum Action {
	        case tab1(CounterFeature.Action)
	        case tab2(CounterFeature.Action)
	    }
	    
	    var body: some ReducerOf<Self> {
	        
	        Scope(state: \.tab1, action: \.tab1) {
	            CounterFeature()
	        }
	        
	        Scope(state: \.tab2, action: \.tab2) {
	            CounterFeature()
	        }
	        
	        Reduce { state, action in
	            return .none
	        }
	    }
	}
	
	struct AppView: View {
	    let store1: StoreOf<CounterFeature>
	    let store2: StoreOf<CounterFeature>
	    
	    var body: some View {
	        TabView {
	            CounterView(store: store1)
	                .tabItem {
	                    Text("Counter 1")
	                }
	            
	            CounterView(store: store2)
	                .tabItem {
	                    Text("Counter 2")
	                }
	        }
	    }
	}
	```
### Section 2 - AppFeatureTest.swift
- 주석 필요 없음
	```swift
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
	```

CounterFeature 2개를 바로 쓰는 것이 아니라, AppFeature를 하나 더 만들어서, 필요 Feature들을 포함한다.
해당 Feature들의 Action과 mutation들을 Scope로 지정하며, 묶어줄 수 있다.
Test도 가능하다!

## Section 3 - Deriving child stores
---
이제 TabView에서 사용하는 모든 Feature를 AppFeature로 묶어 선언했으니, View를 깔끔하게 선언해보자.
### Section 3 - AppFeature.swift
- 주석 필요 없음
	```swift
	//
	//  AppFeature.swift
	//  SwiftUI-TCA-Study
	//
	//  Created by 박민서 on 9/4/24.
	//
	
	import ComposableArchitecture
	import SwiftUI
	
	@Reducer
	struct AppFeature {
	    struct State: Equatable {
	        var tab1 = CounterFeature.State()
	        var tab2 = CounterFeature.State()
	    }
	    
	    enum Action {
	        case tab1(CounterFeature.Action)
	        case tab2(CounterFeature.Action)
	    }
	    
	    var body: some ReducerOf<Self> {
	        
	        Scope(state: \.tab1, action: \.tab1) {
	            CounterFeature()
	        }
	        
	        Scope(state: \.tab2, action: \.tab2) {
	            CounterFeature()
	        }
	        
	        Reduce { state, action in
	            return .none
	        }
	    }
	}
	
	struct AppView: View {
	//    let store1: StoreOf<CounterFeature>
	//    let store2: StoreOf<CounterFeature>
	    let store: StoreOf<AppFeature>
	    
	    var body: some View {
	        TabView {
	            // use scope on store
	            // to derive a child store - tab1
	            CounterView(store: store.scope(state: \.tab1, action: \.tab1))
	                .tabItem {
	                    Text("Counter 1")
	                }
	            
	            CounterView(store: store.scope(state: \.tab2, action: \.tab2))
	                .tabItem {
	                    Text("Counter 2")
	                }
	        }
	    }
	}
	
	#Preview {
	    AppView(store: Store(initialState: AppFeature.State()) {
	        AppFeature()
	    })
	}
	```
필요한 Reducer들을 하나의 AppFeature로 묶고, Scope를 통해 관리하며, View와 Preview에도 적용한 모습이다.