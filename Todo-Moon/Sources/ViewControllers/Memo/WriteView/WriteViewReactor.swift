//
//  WriteViewReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/09.
//

import ReactorKit
import RxCocoa
import RxSwift

final class WriteViewReactor: Reactor {
    
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
        var canSubmit: Bool = false
        
        var title: String = ""
        var selectNumber: Int = 0
        var content: String = ""
    }
    
    let provider: ServiceProviderType
    let initialState: State
    
    init(_ provider: ServiceProviderType) {
        self.provider = provider
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .close:
            return .just(.dismiss)
            
        case let .updateText(title, content):
            return Observable.concat([
                Observable.just(.updateText(title: title, content: content)),
                Observable.just(.validateCanSubmit)
            ])
            
        case .submit:
            
            guard self.currentState.canSubmit else { return .empty() }
            return self.provider.coreDataService.createMemo(title: currentState.title,
                                                            contents: currentState.content)
            .map { _ in
                return .dismiss
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .dismiss:
            state.isDismissed = true
            
            // TODO: contentTextView place holder랑 충돌
        case .validateCanSubmit:
            if state.title.count != 0 && state.selectNumber != 0 && state.content != nil {
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
