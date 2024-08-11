---
date: 2024-08-12
tags:
  - TCA
  - Study
---
## Section 1 - Testing state changes
---
TCA에서 기능, feature를 테스트하기 위해 필요한 건 reducer 하나이다.
이는 아래에 기술하는 두 가지를 테스트 함으로써 진행된다.
- action이 send 되었을 때 어떻게 state가 변경되는 지
- 어떻게 effect가 수행되고, 결과 값을 리듀서에 다시 반환하는 지

State의 변경은 테스트는 다음과 같이 이루어진다.
State와 Action을 reducer에 전달한 다음, State가 어떻게 변경되었는지에 대해 단언(assert) 하면 된다.
> 단언 : assert - 프로그래밍에서 코드가 특정 조건을 만족하는지 확인하는 방법
> - 주로 테스트 코드에서 사용된다.
> - 특정 조건이 true인지 확인하고, 그렇지 않으면 테스트를 실패로 처리(오류 발생)한다.

TCA에서 테스트를 진행할 때, TestStore를 사용한다.
TestStore는 테스트 가능한 런타임으로, 시스템상에서 action의 처리 과정을 모두 모니터링하며, 해당 부분에서 단언(assert)을 진행할 수 있다.
### Section 1 - CounterFeatureTests.swift
---
- 한글 주석 코드
	```swift
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
	    @MainActor // MainActor shouldn't be with non-isolated class - Swift 6
	    func testCounter() async { // TCA testing tool use asynchrony.
	        // make TestStore in the same way creating a Store
	        let store = TestStore(initialState: CounterFeature.State()) { // TestStore requires State to conform Equatable protocol - to make its assertion
	            CounterFeature()
	        }
	        
	        // start sending actions into TestStore
	        // you have to describe the State after Action is sent
	        await store.send(.incrementButtonTapped) {
	            // you have to provide assertion
	            // $0 is mutable version of the State before the action is sent - change
	            // mutate $0 so that it equals the state after the action is sent - change
	            $0.count = 1
	        }
	
	        await store.send(.decrementButtonTapped) {
	            // prefer to use 'absolute' mutation like `= 0`.
	            // `= 0`, absolute assetion knows exact state
	            // `+= 1`, relative assertion merely knows what transformation was applied to state
	            $0.count = 0
	        }
	    }
	}
	```

- 영어 주석 코드
	```swift
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
	```
- 코드 핵심 정리
	- **TestStore 생성**:
	    - **TestStore**: TCA에서 State와 Action을 테스트하기 위해 사용하는 도구이다. 실제 애플리케이션에서 사용하는 Store와 비슷하게 동작하지만, 테스트 환경에 맞게 조정된 기능을 제공한다.
	    - **TestStore 초기화**: TestStore는 테스트할 State와 Reducer를 받아 초기화한다. 이때 State와는 Equatable 프로토콜을 준수해야 한다.
	-  **비동기 테스트 지원**:
	    - **비동기 테스트**: TCA 테스트는 비동기로 실행된다. 따라서 테스트 함수는 async로 선언되며, await키워드를 사용해 async action 전송과 state 검증을 수행한다.
	-  **Action 전송 및 State 검증**:
	    - **Action 전송(send)**: store.send 메서드를 사용해 특정 Action을 TestStore에 전송한다. 이때 Action이 발생한 후의 State를 클로저 내에서 검증한다.
	    - **State 검증**: Action이 전송된 후 State가 올바르게 변경되었는지 확인하기 위해, 테스트에서 State를 수정(`$0.count = 1`)하여 예상되는 State와 일치하도록 만든다.
		    - 상태를 검증할 때는 절대적 검증(`= 0`)을 사용하는 것이 권장된다. 
		    - 절대적 검증은 상태가 정확히 일치하는지 확인할 수 있어, 상대적 검증(`+= 1`)보다 더 명확하고 신뢰할 수 있다.