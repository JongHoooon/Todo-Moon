//
//  TaskCellReactor.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import ReactorKit
import RxCocoa
import RxSwift

final class TaskCellReactor: Reactor {
    
    enum Action {
        case tapBox
    }
    
    enum Mutation {
        case tapBox
    }
    
    struct State {
        var todo: Todo
        var isEnabled: Bool
    }
    
    let provider: ServiceProviderType
    let initialState: State
    let checkedCellIdRelay: BehaviorRelay<String>
    
    init(_ provider: ServiceProviderType,
         todo: Todo,
         isEnabled: Bool = false,
         checkRelay: BehaviorRelay<String>) {
        self.provider = provider
        self.initialState = State(todo: todo, isEnabled: isEnabled)
        self.checkedCellIdRelay = checkRelay
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapBox:
            // todoViewReactor 에게 업데이트하도록 선택된 id를 전달한다.
            checkedCellIdRelay.accept(currentState.todo.identity)
            return self.provider.todoService.tapCheckButton()
                .map { _ in .tapBox }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .tapBox:
            state.todo.isChecked.toggle()
        }
        
        return state
    }
}
