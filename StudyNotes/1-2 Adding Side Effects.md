---
date: 2024-08-10
tags:
  - TCA
  - Study
---
## Section 1 - What is a side effect?
---

Side effect (부작용)은 기능 개발에서 중요한 측면이다.

API 통신 요청, 파일 시스템 상호작용, 비동기 처리 등 외부 시스템과 상호작용을 할 수 있게 해준다.

동시에 Side effect는 가장 복잡한 측면이기도 하다.

State 변경의 경우 같은 action은 항상 같은 결과로 변경된다. 하지만 Effects의 경우 외부 시스템의 변경사항에 취약하다. 네트워크 연결 상태, 디스크 접근 권한 등이 effect에 영향을 주는 요소들의 예시가 될  것이다.

따라서 같은 effect를 진행시켜도 전혀 다른 결과를 받을 수 있음을 유의하자.

이제 코드를 통해서 Reducer를 통해 왜 효과적인 작업을 직접 수행할 수 없는지 보고, effect를 수행하는 라이브러리를 볼 것이다.

### Section 1 - CounterView.swift
---

- 주석 추가 없음 코드
    
    ```swift
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
                    .clipShape(.rect(cornerRadius: 10))
                
                HStack {
                    Button("-") {
                        // You can send actions to the store via send(_:).
                        store.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                    
                    Button("+") {
                        store.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                }
                
                Button("Fact") {
                    store.send(.factButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                
                if store.isLoading {
                        ProgressView()
                } else if let fact = store.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
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
    
    ```
    

### Section 1 - CounterFeature.swift
---

- 한글 주석
    
    ```jsx
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
        // 0. Reducer를 준수하기 위해 State, Action, Body를 생성합니다.
        // 1. State - 기능에서 필요로 하는 데이터의 상태를 정의합니다.
        // 2. Action - 사용자가 기능 내에서 수행할 수 있는 액션을 정의합니다.
        // 3. Body - 각 Action에 따라 상태를 업데이트하는 리듀서를 포함합니다.
        
        @ObservableState // 이 기능을 SwiftUI에서 관찰하려면 사용합니다.
        struct State {
            var count = 0
            var fact: String?
            var isLoading = false
        }
        
        enum Action {
            // UI에서 사용자가 수행하는 동작에 따라 액션의 이름을 정합니다.
            case decrementButtonTapped
            case incrementButtonTapped
            case factButtonTapped
        }
        
        var body: some ReducerOf<Self> {
            // body는 Reduce 리듀서로 선언해야 합니다.
            // - 하나 이상의 리듀서를 이 body에서 조합할 수 있습니다.
            // - 조합하려는 리듀서를 나열합니다.
            Reduce { state, action in
                // state는 inout으로 제공되어 직접 변경할 수 있습니다.
                switch action {
                    // 각 액션에 따라 상태를 업데이트하는 로직을 정의합니다.
                    // 경우에 따라 외부에서 실행할 효과를 반환할 수 있습니다.
                case .decrementButtonTapped:
                    state.count -= 1
                    state.fact = nil
                    return .none // Effect를 반환해야 합니다.
                    // Effect - 외부에서 실행할 작업
                    // 아무 작업이 없으면 .none을 반환합니다.
                case .incrementButtonTapped:
                    state.count += 1
                    state.fact = nil
                    return .none
                    
                case .factButtonTapped:
                    state.fact = nil
                    state.isLoading = true
                    
                    // TCA는 여기서 비동기 작업을 허용하지 않습니다.
                    // 비동기 작업은 Side Effect로 처리되어야 합니다.
    //                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)
                    // 🛑 이 함수에서는 'async' 호출을 지원하지 않습니다.
                    // 🛑 여기서 발생한 에러는 처리되지 않습니다.
                    
    //                state.fact = String(decoding: data, as: UTF8.self)
                    state.isLoading = false
                    return .none
                }
            }
        }
    }
    
    ```
    
- 영어 주석
    
    ```jsx
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
    
    ```
    
- 코드 핵심 정리
    - **Reducer와 Side Effect의 분리:**
        - 비동기 API  호출과 같은 작업은 Reducer 내에서 직접 실행할 수 없으며, 대신 Effect를 통해 처리해야 한다.
        - 이는 비동기 작업의 실행 위치를 분리하여 코드의 명확성과 유지보수성을 높이기 위함이다.

## Section 2 - Performing a network request
---

이제 side effect가 무엇인지 알고, 왜 reducer에서 직접 수행이 불가능한 지 확인했다.

reducer의 state를 변경하며 액션을 처리한 후에는, Effect라고 칭하는 것을 반환한다.

Effect는 해당 Store에 의해 진행되는 비동기 단위를 의미한다. 이 Effect는 외부 시스템과 데이터 통신이 가능하며, 다시 reducer에게 데이터를 전달해주는 역할을 한다.

이제 코드를 통해서 네트워크 통신 후 결과 데이터를 reducer에 전달받는 것까지 알아보도록 하자.

### Section 2 - CounterFeature.swift
---

- 한글 주석
    
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
        // 0. Reducer를 준수하기 위해 State, Action, Body를 생성합니다.
        // 1. State - 기능에서 필요로 하는 데이터의 상태를 정의합니다.
        // 2. Action - 사용자가 기능 내에서 수행할 수 있는 액션을 정의합니다.
        // 3. Body - 각 Action에 따라 상태를 업데이트하는 리듀서를 포함합니다.
        
        @ObservableState // 이 기능을 SwiftUI에서 관찰하려면 사용합니다.
        struct State {
            var count = 0
            var fact: String?
            var isLoading = false
        }
        
        enum Action {
            // UI에서 사용자가 수행하는 동작에 따라 액션의 이름을 정합니다.
            case decrementButtonTapped
            case incrementButtonTapped
            case factButtonTapped
            case factResponse(String)
        }
        
        var body: some ReducerOf<Self> {
            // body는 Reduce 리듀서로 선언해야 합니다.
            // - 하나 이상의 리듀서를 이 body에서 조합할 수 있습니다.
            // - 조합하려는 리듀서를 나열합니다.
            Reduce { state, action in
                // state는 inout으로 제공되어 직접 변경할 수 있습니다.
                switch action {
                    // 각 액션에 따라 상태를 업데이트하는 로직을 정의합니다.
                    // 경우에 따라 외부에서 실행할 효과를 반환할 수 있습니다.
                case .decrementButtonTapped:
                    state.count -= 1
                    state.fact = nil
                    return .none // Effect를 반환해야 합니다.
                    // Effect - 외부에서 실행할 작업
                    // 아무 작업이 없으면 .none을 반환합니다.
                case .incrementButtonTapped:
                    state.count += 1
                    state.fact = nil
                    return .none
                    
                case .factButtonTapped:
                    state.fact = nil
                    state.isLoading = true
                    
                    // TCA는 Side Effect를 분리합니다. - 여기서 허용되지 않음
                    // 비동기 작업은 Side Effect로 처리되어야 합니다.
    //                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)
    //                state.fact = String(decoding: data, as: UTF8.self)
    //                state.isLoading = false
                    // 🛑 이 함수에서는 'async' 호출을 지원하지 않습니다.
                    // 🛑 여기서 발생한 에러는 처리되지 않습니다.
                    
                    // Effect를 생성하는 방법 중 하나는 .run을 사용하는 것입니다.
                    // 이는 비동기 작업을 위한 컨텍스트를 제공합니다.
                    return .run { [count = state.count] send in
                        // ✅ 여기에서 비동기 작업을 수행하고, 작업이 완료되면 액션을 시스템으로 다시 보냅니다.
                        let (data, _) = try await URLSession.shared
                            .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                        let fact = String(decoding: data, as: UTF8.self)
                        
                        // state.fact = fact
                        // 🛑 동시에 실행되는 코드에서는 'inout' 파라미터 'state'의 변경을 허용하지 않습니다.
                        
                        // 비동기 작업을 수행한 후, 데이터를 포함한 액션을 다른 액션으로 보냅니다.
                        // 이를 통해 Effect에서 가져온 정보를 리듀서에 다시 전달할 수 있습니다.
                        await send(.factResponse(fact))
                        
                    }
                    
                case .factResponse(let fact):
                    state.fact = fact
                    state.isLoading = false
                    return .none
                }
            }
        }
    }
    
    ```
    
- 영어 주석
    
    ```swift
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
            case factResponse(String)
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
                }
            }
        }
    }
    
    ```
    
- 코드 핵심 정리
    - **비동기 작업 처리:**
        - 비동기 작업은 Effect.run을 사용하여 수행된다.
        - 이 메서드는 비동기 작업을 실행할 수 있는 컨텍스트를 제공한다.
    - **Effect.run 사용**:
        - Effect.run 블록 내에서 네트워크 요청을 수행하고, 그 결과를 다른 액션을 통해 리듀서로 전달한다. 이를 통해 비동기 작업의 결과를 안전하게 리듀서에 반영할 수 있다.
        - 비동기 작업이 완료되면 await send(.factResponse(fact))을 통해 결과를 리듀서에 다시 전달한다.
    - **상태 변경의 안전성**:
        - 비동기 작업 중 state를 직접 수정하는 것이 금지되어 있기 때문에, 작업이 완료된 후 결과를 리듀서에 전달하여 상태를 안전하게 업데이트한다.

## Section 3 - Managing a timer
---

네트워크 요청은 side effect의 대표적 예시 중 하나이다.

하지만 네트워크 요청만이 side effect가 아니기에, 타이머 기능을 구현하면서 더 확인해보자.

### Section 3 - CounterView.swift
---

- 주석 추가 없음 코드
    
    ```swift
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
                    .clipShape(.rect(cornerRadius: 10))
                
                HStack {
                    Button("-") {
                        // You can send actions to the store via send(_:).
                        store.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                    
                    Button("+") {
                        store.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                }
                
                Button(store.isTimerRunning ? "Stop timer" : "Start timer") {
                    store.send(.toggleTimerButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10) 
                
                Button("Fact") {
                    store.send(.factButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                
                if store.isLoading {
                        ProgressView()
                } else if let fact = store.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
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
    
    ```
    

### Section 3 - CounterFeature.swift
---

- 한글 주석
    
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
        // 0. Reducer를 준수하기 위해 State, Action, Body를 생성합니다.
        // 1. State - 기능에서 필요로 하는 데이터의 상태를 정의합니다.
        // 2. Action - 사용자가 기능 내에서 수행할 수 있는 액션을 정의합니다.
        // 3. Body - 각 Action에 따라 상태를 업데이트하는 리듀서를 포함합니다.
        
        @ObservableState // 이 기능을 SwiftUI에서 관찰하려면 사용합니다.
        struct State {
            var count = 0
            var fact: String?
            var isLoading = false
            var isTimerRunning = false
        }
        
        enum Action {
            // UI에서 사용자가 수행하는 동작에 따라 액션의 이름을 정합니다.
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
            // body는 Reduce 리듀서로 선언해야 합니다.
            // - 하나 이상의 리듀서를 이 body에서 조합할 수 있습니다.
            // - 조합하려는 리듀서를 나열합니다.
            Reduce { state, action in
                // state는 inout으로 제공되어 직접 변경할 수 있습니다.
                switch action {
                    // 각 액션에 따라 상태를 업데이트하는 로직을 정의합니다.
                    // 경우에 따라 외부에서 실행할 효과를 반환할 수 있습니다.
                case .decrementButtonTapped:
                    state.count -= 1
                    state.fact = nil
                    return .none // Effect를 반환해야 합니다.
                    // Effect - 외부에서 실행할 작업
                    // 아무 작업이 없으면 .none을 반환합니다.
                case .incrementButtonTapped:
                    state.count += 1
                    state.fact = nil
                    return .none
                    
                case .factButtonTapped:
                    state.fact = nil
                    state.isLoading = true
                    
                    // TCA는 Side Effect를 분리합니다. - 여기서 허용되지 않음
                    // 비동기 작업은 Side Effect로 처리되어야 합니다.
                    //                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)
                    //                state.fact = String(decoding: data, as: UTF8.self)
                    //                state.isLoading = false
                    // 🛑 이 함수에서는 'async' 호출을 지원하지 않습니다.
                    // 🛑 여기서 발생한 에러는 처리되지 않습니다.
                    
                    // Effect를 생성하는 방법 중 하나는 .run을 사용하는 것입니다.
                    // 이는 비동기 작업을 위한 컨텍스트를 제공합니다.
                    return .run { [count = state.count] send in
                        // ✅ 여기에서 비동기 작업을 수행하고, 작업이 완료되면 액션을 시스템으로 다시 보냅니다.
                        let (data, _) = try await URLSession.shared
                            .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                        let fact = String(decoding: data, as: UTF8.self)
                        
                        // state.fact = fact
                        // 🛑 동시에 실행되는 코드에서는 'inout' 파라미터 'state'의 변경을 허용하지 않습니다.
                        
                        // 비동기 작업을 수행한 후, 데이터를 포함한 액션을 다른 액션으로 보냅니다.
                        // 이를 통해 Effect에서 가져온 정보를 리듀서에 다시 전달할 수 있습니다.
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
                                // 매초 이 액션을 전송합니다.
                                await send(.timerTick)
                            }
                        }
                        // Effect 취소
                        // 이 효과는 .cancel(id:) 효과를 사용하여 취소할 수 있습니다.
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
    
- 영어 주석
    
    ```swift
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
    
    ```
    
- 코드 핵심 정리
    - **Effect를 통한 타이머 구현**:
        - **Effect.run**: 타이머를 시작할 때 Effect.run을 사용하여 비동기적으로 매초마다 timerTick Action을 발생시킨다.
        - **Effect 취소**: 타이머가 중지될 때는 CancelID.timer를 사용하여 해당 Effect를 취소한다. 이를 통해 타이머를 안전하게 중지할 수 있다.
    - **Effect 취소 기능**:
        - **CancelID 열거형**: 이를 통해 타이머와 관련된 작업을 식별하고, 필요한 경우 해당 작업을 취소할 수 있다.