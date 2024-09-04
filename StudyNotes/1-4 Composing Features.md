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
TCA에서는 여러 개의 독립된 Store가 아닌 하나의 Store에서 기능을 함께 구성하고 View를 제공하는 것을 선호한다.
일단 넘어가보자

## Section 2 - Composing reducers
---
여러 개의 독립된 Store를 가진 이상적이지 않은 환경을, reducer 단계에서 고쳐가보자.
