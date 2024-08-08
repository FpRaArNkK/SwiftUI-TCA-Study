# 1-1. Your First Feature

태그: Essentials

## Section 1 - Create a reducer

---

The Composable Architecture의 기본 핵심 기능은 `Reducer() 매크로`와 `Reducer 프로토콜`이다.

Reducer 프로토콜을 준수함으로써 Reducer의 로직과 기능을 추가할 수 있게 된다.

Reducer엔 아래에 기술되는 내용이 포함된다.

- action이 send 되었을 때, 현재 state에서 다음 state로 변경되는 과정
- 해당 시스템에서 외부의 시스템으로 effect를 끼치거나, 데이터를 통신하는 방법

중요한 것은, Reducer의 코어 로직과 기능은 SwiftUI View에 별도의 기능 작성 없이 독립적이라는 것이다.

→ 서로 모듈화되어 재사용하기 쉽고, 테스트하기 쉽게 된다.

### Section 1 - CounterFeature.swift

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
    
    @Reducer // Reducer 매크로 주석
    struct CounterFeature {
        // 0. Reducer를 준수하기 위해 State, Action, Body를 생성합니다.
        // 1. State - 기능에서 필요로 하는 데이터의 상태를 정의합니다.
        // 2. Action - 사용자가 기능 내에서 수행할 수 있는 액션을 정의합니다.
        // 3. Body - 각 Action에 의해 상태가 변화하는 로직을 작성합니다.
        
        @ObservableState // SwiftUI에서 이 기능을 관찰하려면 사용합니다.
        struct State {
            var count = 0
        }
        
        enum Action {
            // UI에서 사용자가 수행하는 동작에 따라 액션의 이름을 정합니다.
            case decrementButtonTapped
            case incrementButtonTapped
        }
        
        var body: some ReducerOf<Self> {
            // body는 Reduce 리듀서로 선언해야 합니다.
            // - 하나 이상의 리듀서를 이 body에서 조합할 수 있습니다.
            // - 조합하고자 하는 리듀서를 나열합니다.
            Reduce { state, action in
                // state는 inout으로 제공되어 직접 변경할 수 있습니다.
                switch action {
                    // 각 액션으로 상태가 어떻게 변화하는지 정의합니다.
                    // 경우에 따라 외부에서 실행할 효과를 반환할 수 있습니다.
                case .decrementButtonTapped:
                    state.count -= 1
                    return .none // Effect를 반환해야 합니다.
                    // Effect - 외부에서 실행할 작업
                    // 아무 작업이 없으면 .none을 반환합니다.
                case .incrementButtonTapped:
                    state.count += 1
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
    //  Created by Minseo Park on 8/8/24.
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
    
    ```
    

여기까지가 TCA의 기본적인 기능 수행을 위한 코드 작성이다.

effect를 수행하거나, 데이터를 시스템에 다시 전달, reducer에서 의존성 사용, 여러 개의 reducer를 compose 하는 등의 로직 작성은 뒤에서 다룬다.

## Section 2 - Integrating with SwiftUI

---

## Section 3 - Intergrating into the app

---