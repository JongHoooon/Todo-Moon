//
//  MemoEditViewReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/23.
//

import ReactorKit
import RxCocoa
import RxSwift

final class MemoEditViewReactor: Reactor {
    
    enum Action {
        case close
        case updateText(title: String, content: String)
        case submit
    }
    
    enum Mutation {
        case dismiss
        
        case validateCanSubmit
        case updateText(title: String, content: String)
    }
    
    struct State {
        var isDismissed: Bool = false
        var canSubmit: Bool = true
        
        var title: String
        var content: String
        var memo: Memo
    }
    
    let provider: ServiceProviderType
    var initialState: State
    
    init(provider: ServiceProviderType, memo: Memo) {
        self.provider = provider
        self.initialState = State(title: memo.title ?? "",
                                  content: memo.contents ?? "",
                                  memo: memo)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        var newMutation: Observable<Mutation>
        switch action {
        case .close:
            newMutation = .just(.dismiss)
            
        case let .updateText(title, content):
            newMutation = Observable.concat([
                Observable.just(.updateText(title: title, content: content)),
                Observable.just(.validateCanSubmit)
            ])
            
        case .submit:
            guard self.currentState.canSubmit else { return .empty() }
            
            return self.provider.coreDataService.editMemo(memo: currentState.memo,
                                                          title: currentState.title,
                                                          contents: currentState.content)
            .map({ [weak self] memo in
                
                self?.provider.memoService.editMemo(memo: memo)

                return .dismiss
            })
        }
        
        return newMutation
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .dismiss:
            state.isDismissed = true
            
        case .validateCanSubmit:
            if state.title.count != 0 && state.content.count != 0 {
                state.canSubmit = true
            } else {
                state.canSubmit = false
            }
            
        case .updateText(title: let title, content: let content):
            state.title = title
            state.content = content
        }
        
        return state
    }
}
