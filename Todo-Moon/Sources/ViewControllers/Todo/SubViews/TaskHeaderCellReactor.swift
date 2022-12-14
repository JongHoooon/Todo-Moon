//
//  TaskHeaderCellReactor.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import ReactorKit
import RxCocoa
import RxSwift

final class TaskHeaderCellReactor: Reactor {
  
  enum Action {
    case plusTask
  }
  
  enum Mutation {
    case empty
  }
  
  struct State {
    
  }
  
  // MARK: - Property
  
  let provider: ServiceProviderType
  let initialState = State()
  
  // MARK: - Init
  
  init(_ provider: ServiceProviderType) {
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    
    switch action {
    case .plusTask:
      return self.provider.todoService.tapCreateButton()
        .map { .empty }
    }
  }
}
