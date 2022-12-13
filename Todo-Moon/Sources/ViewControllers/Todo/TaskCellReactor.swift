//
//  TaskCellReactor.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import ReactorKit
import RxCocoa
import RxSwift

final class TaskCellReactor: Reactor, BaseReactorType {
  
  
  enum Action {
    case tapBox
  }
  
  enum Mutation {
    case tapBox
  }
  
  struct State {
    var task: Task
    var isEnabled: Bool
  }
  
  let userInfo: UserInfo
  let provider: ServiceProviderType
  let initialState: State
  let checkedCellIdRelay: BehaviorRelay<String>
  
  init(_ provider: ServiceProviderType, userInfo: UserInfo, task: Task, isEnabled: Bool = false, checkRelay: BehaviorRelay<String>) {
    self.userInfo = userInfo
    self.provider = provider
    self.initialState = State(task: task, isEnabled: isEnabled)
    self.checkedCellIdRelay = checkRelay
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .tapBox:
      // todoViewReactor 에게 업데이트하도록 선택된 id를 전달한다.
      checkedCellIdRelay.accept(currentState.task.id)
      return self.provider.todoService.tapCheckButton()
        .map { _ in .tapBox }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .tapBox:
      state.task.isChecked?.toggle()
    }
    
    return state
  }
}
