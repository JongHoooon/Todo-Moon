//
//  MemoDetailViewReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/11.
//

import ReactorKit
import RxCocoa
import RxSwift

final class MemoDetailViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        case eidtMemo(Memo)
    }
    
    struct State {
        var memo: Memo?
    }
    
    let provider: ServiceProviderType
    var initialState: State
    
    init(_ provider: ServiceProviderType) {
        self.provider = provider
        self.initialState = State()
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        
        let memoEditMutation = self.provider.memoService.memoEvent
            .flatMap { [weak self] memoEvent -> Observable<Mutation> in
                self?.mutate(memoEvent: memoEvent) ?? .empty()
            }
        
        return Observable.of(mutation, memoEditMutation).merge()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func mutate(memoEvent: MemoEvent) -> Observable<Mutation> {
        switch memoEvent {
        case let .edit(memo):
            return .just(.eidtMemo(memo))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .eidtMemo(memo):
            state.memo = memo
        }
        
        return state
    }
}
