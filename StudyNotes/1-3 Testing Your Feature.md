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

Reducer가 갖는 첫번째 책임인 State의 변경 테스트는 다음과 같이 이루어진다.
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

## Section 2 - Testing effects
---
다음으로 중요한 reducer의 두번째 책임은 store에서 처리한 후 리턴하는 effect들이다.

side effect에 대한 테스트를 진행하기 위해서는 아래의 내용을 이행해야한다.
- 외부 시스템의 종속성을 컨트롤하면서
- 테스트 친화적인 종속성들을 제공

### Section 2 - CounterFeature.swift
---
- 한글 주석 코드
	```swift
	//
	//  CounterFeature.swift
	//  SwiftUI-TCA-Study
	//
	//  Created by 박민서 on 8/8/24.
	//
	
	import ComposableArchitecture
	import Foundation
	
	@Reducer // Reducer 매크로 주석
	struct CounterFeature {
	    // 0. Reducer를 준수하기 위해 State, Action 및 Body를 생성합니다.
	    // 1. State - 기능에서 필요한 데이터 상태를 정의합니다.
	    // 2. Action - 사용자가 기능에서 수행할 수 있는 작업을 정의합니다.
	    // 3. Body - Actions에 따라 States를 업데이트하는 리듀서를 포함합니다.
	    
	    @ObservableState // 이 기능을 SwiftUI에서 관찰할 때 사용하십시오.
	    struct State: Equatable {
	        var count = 0
	        var fact: String?
	        var isLoading = false
	        var isTimerRunning = false
	    }
	    
	    enum Action {
	        // UI에서 사용자가 수행하는 작업에 따라 Action에 이름을 지정합니다.
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
	    
	    @Dependency(\.continuousClock) var clock
	    
	    var body: some ReducerOf<Self> {
	        // body는 반드시 Reduce 리듀서로 선언되어야 합니다.
	        // - 하나 이상의 리듀서를 이 body에 구성할 수 있습니다.
	        // - 구성하려는 리듀서를 나열합니다.
	        Reduce { state, action in
	            // state는 inout으로 제공되므로 직접 수정할 수 있습니다.
	            switch action {
	                // 각 action에 대해 상태를 업데이트하는 로직을 정의합니다.
	                // 일부 경우에는 외부에서 실행할 effect를 반환합니다.
	            case .decrementButtonTapped:
	                state.count -= 1
	                state.fact = nil
	                return .none // 반드시 Effect를 반환해야 합니다.
	                // Effect - 외부에서 실행될 작업.
	                // 아무 것도 없으면 .none을 반환합니다.
	            case .incrementButtonTapped:
	                state.count += 1
	                state.fact = nil
	                return .none
	                
	            case .factButtonTapped:
	                state.fact = nil
	                state.isLoading = true
	                
	                // TCA는 사이드 이펙트를 분리합니다. - 여기서는 허용되지 않음
	                // 이 비동기 호출은 사이드 이펙트로 실행되어야 합니다.
	                //                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)
	                //                state.fact = String(decoding: data, as: UTF8.self)
	                //                state.isLoading = false
	                // 🛑 'async' 함수는 동시성(concurrency)을 지원하지 않는 함수 내에서 호출될 수 없습니다.
	                // 🛑 여기에서 발생한 오류는 처리되지 않습니다.
	                
	                // .run을 사용하여 Effect를 구성하는 한 가지 방법입니다.
	                // 이 방법은 비동기 컨텍스트를 제공합니다.
	                return .run { [count = state.count] send in
	                    // ✅ 여기에서 비동기 작업을 수행하고, 작업 후 액션을 시스템으로 다시 보냅니다.
	                    let (data, _) = try await URLSession.shared
	                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
	                    let fact = String(decoding: data, as: UTF8.self)
	                    
	                    // state.fact = fact
	                    // 🛑 'inout' 파라미터 'state'를 비동기적으로 실행되는 코드 내에서 변경할 수 없습니다.
	                    
	                    // 비동기 작업을 수행한 후, 데이터를 포함한 다른 액션을 전송합니다.
	                    // 이를 통해 효과(effect)로부터 정보를 리듀서로 다시 전달할 수 있습니다.
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
	                        // 외부에서 continuousClock 사용
	                        for await _ in self.clock.timer(interval: .seconds(1)) {
	                            await send(.timerTick)
	                        }
	//                        while true {
	//                            try await Task.sleep(for: .seconds(1))
	//                            // 매 초마다 이 액션을 보냅니다.
	//                            await send(.timerTick)
	//                        }
	                    }
	                    // Effect 취소
	                    // .cancel(id:) 효과를 사용하여 취소할 수 있습니다.
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
	
	```
- 영어 주석 코드
	```swift
	//
	//  CounterFeature.swift
	//  SwiftUI-TCA-Study
	//
	//  Created by Minseo Park on 8/8/24.
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
	    
	    @Dependency(\.continuousClock) var clock
	    
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
	                
	                // TCA Separates Side Effects. - not allowed here
	                // This asynchronous call should be executed as a side effect
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
	                        // use continuousClock from external dependency
	                        for await _ in self.clock.timer(interval: .seconds(1)) {
	                            await send(.timerTick)
	                        }
	//                        while true {
	//                            try await Task.sleep(for: .seconds(1))
	//                            // Send this action every second
	//                            await send(.timerTick)
	//                        }
	                    }
	                    // Effect cancellation
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
	
	```
### Section 2- CounterFeatureTests.swift
----
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
	    @MainActor // MainActor는 격리되지 않은 클래스와 함께 사용하지 않아야 합니다 - Swift 6
	    func testCounter() async { // TCA 테스트 도구는 비동기 방식을 사용합니다.
	        // Store를 생성하는 것과 동일한 방식으로 TestStore를 생성합니다.
	        let store = TestStore(initialState: CounterFeature.State()) { // TestStore는 State가 Equatable 프로토콜을 준수해야 합니다 - 이는 assertion을 위해 필요합니다.
	            CounterFeature()
	        }
	        
	        // TestStore에 액션을 전송하기 시작합니다.
	        // 액션이 전송된 후의 State를 설명해야 합니다.
	        await store.send(.incrementButtonTapped) {
	            // Assertion을 제공해야 합니다.
	            // $0은 액션이 전송되기 전의 State의 변경 가능한 버전입니다.
	            // $0을 변경하여 액션이 전송된 후의 상태와 동일하게 만듭니다.
	            $0.count = 1
	        }
	
	        await store.send(.decrementButtonTapped) {
	            // `= 0`과 같은 '절대적' 변화를 사용하는 것이 좋습니다.
	            // `= 0`은 정확한 상태를 알고 있는 절대적인 assertion입니다.
	            // `+= 1`은 상태에 어떤 변화가 적용되었는지를 아는 상대적인 assertion입니다.
	            $0.count = 0
	        }
	    }
	    
	    @MainActor
	    func testTimer() async {
	        // 이 클럭은 기능 리듀서에서 사용됩니다.
	        let clock = TestClock()
	        
	        let store = TestStore(initialState: CounterFeature.State()) {
	            CounterFeature()
	        } withDependencies: {
	            // 의존성 주입.
	            $0.continuousClock = clock
	        }
	        
	        await store.send(.toggleTimerButtonTapped) {
	            $0.isTimerRunning = true
	        }
	        // ❌ 이 액션에 대해 반환된 효과가 아직 실행 중입니다.
	        //    테스트가 끝나기 전에 완료되어야 합니다. …
	        // TestStore는 기능이 시간에 따라 어떻게 발전하는지, 특히 효과(effect)를 포함하여 강제적으로 assert하게 만듭니다.
	        
	        await clock.advance(by: .seconds(1))
	        await store.receive(\.timerTick) {
	            $0.count = 1
	        }
	        
	        // 타이머 동작에 대한 assertion 추가.
	//        await store.receive(\.timerTick, timeout: .seconds(2)) { // Action enum에서 특정 액션을 선택하기 위해 키 경로를 사용하고 명시적 타임아웃 체크를 합니다.
	//            $0.count = 1
	//            // ✅ 테스트 스위트 '선택된 테스트'가 통과했습니다.
	//            //        1개의 테스트가 실행되었으며, 0개의 실패(0개의 예상치 못한 실패)로 1.044 (1.046) 초 내에 완료되었습니다.
	//            //    또는:
	//            // ❌ 예상대로 액션을 받지 못했으며, 0.1초 후에 아무런 액션도 받지 않았습니다.
	//        }
	        
	        await store.send(.toggleTimerButtonTapped) {
	            $0.isTimerRunning = false
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
	//  Created by Minseo Park on 8/12/24.
	//
	
	import ComposableArchitecture
	import XCTest
	
	@testable import SwiftUI_TCA_Study
	
	
	final class CounterFeatureTests: XCTestCase {
	    @MainActor // MainActor shouldn't be used with a non-isolated class - Swift 6
	    func testCounter() async { // TCA testing tool uses asynchrony.
	        // Create a TestStore in the same way you create a Store.
	        let store = TestStore(initialState: CounterFeature.State()) { // TestStore requires State to conform to the Equatable protocol - for assertions.
	            CounterFeature()
	        }
	        
	        // Start sending actions into the TestStore.
	        // You have to describe the State after the Action is sent.
	        await store.send(.incrementButtonTapped) {
	            // You have to provide an assertion.
	            // $0 is a mutable version of the State before the action is sent.
	            // Mutate $0 so that it equals the state after the action is sent.
	            $0.count = 1
	        }
	
	        await store.send(.decrementButtonTapped) {
	            // Prefer to use 'absolute' mutation like `= 0`.
	            // `= 0`, absolute assertion that knows the exact state.
	            // `+= 1`, relative assertion merely knows what transformation was applied to the state.
	            $0.count = 0
	        }
	    }
	    
	    @MainActor
	    func testTimer() async {
	        // This will be the clock used in the feature reducer.
	        let clock = TestClock()
	        
	        let store = TestStore(initialState: CounterFeature.State()) {
	            CounterFeature()
	        } withDependencies: {
	            // Dependency injection.
	            $0.continuousClock = clock
	        }
	        
	        await store.send(.toggleTimerButtonTapped) {
	            $0.isTimerRunning = true
	        }
	        // ❌ An effect returned for this action is still running.
	        //    It must complete before the end of the test. …
	        // Because the TestStore forces you to assert how your entire feature evolves over time, including effects.
	        
	        await clock.advance(by: .seconds(1))
	        await store.receive(\.timerTick) {
	            $0.count = 1
	        }
	        
	        // Add assertion about timer behavior.
	//        await store.receive(\.timerTick, timeout: .seconds(2)) { // Use key path for singling out from Action enum + explicit timeout checker.
	//            $0.count = 1
	//            // ✅ Test Suite 'Selected tests' passed.
	//            //        Executed 1 test, with 0 failures (0 unexpected) in 1.044 (1.046) seconds.
	//            //    or:
	//            // ❌ Expected to receive an action, but received none after 0.1 seconds.
	//        }
	        
	        await store.send(.toggleTimerButtonTapped) {
	            $0.isTimerRunning = false
	        }
	    }
	}
	
	```
- 코드 핵심 정리
	- 타이머 비동기 테스트 시 종속성 주입:
		- 기존 문제: 내부 시스템 타이머는 테스트에서 관리할 수 있는 변수가 아님.
		- 종속성 주입: SwiftClock을 통해 Dependency를 주입하는 구조를 통해 타이머를 적용, 테스트 가능
## Section 3 - Testing network requests
---
네트워킹 통신이 비동기 처리 중 가장 흔한 side effect일 것이다.
네트워킹 통신은 네트워크 연결 상태나 서버 상태 등 예측하지 못하는 변수들로 인해 예측이 힘들다.
따라서 어떤 결과값이 반환될 지 보장할 수 없다.