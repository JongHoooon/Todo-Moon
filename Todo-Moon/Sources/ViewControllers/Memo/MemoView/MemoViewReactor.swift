//
//  MemoViewReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/04.
//

import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources

typealias MemoListSection = SectionModel<Void, MemoViewCellReactor>

final class MemoViewReactor: Reactor {
    
    enum Action {
        case viewDidAppear
        case refresh
        
    }
    
    enum Mutation {
        case setSetcions([MemoListSection])
    }
    
    struct State {
        var sections: [MemoListSection]
    }
    
    // MARK: - Property
    
    let provider: ServiceProviderType
    let initialState: State
    
    // MARK: - Initialize
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        self.initialState = State(sections: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidAppear:
            
            return self.provider.coreDataService.fetchMemos()
                .map({ memos in
                    let sectionItems = memos.map { MemoViewCellReactor.init(memo: $0,
                                                                             provider: self.provider) }
                    let section = MemoListSection(model: Void(), items: sectionItems)
                    return .setSetcions([section])
                })
            
        case .refresh:
            
            return self.provider.coreDataService.fetchMemos()
                .map({ memos in
                    let sectionItems = memos.map { MemoViewCellReactor.init(memo: $0,
                                                                             provider: self.provider) }
                    let section = MemoListSection(model: Void(), items: sectionItems)
                    return .setSetcions([section])
                })
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setSetcions(sections):
            state.sections = sections
            
            return state
        }
    }
}

// MARK: - Method

extension MemoViewReactor {
    
    func reactorForWriteView() -> MemoWriteViewReactor {
        return MemoWriteViewReactor(self.provider)
    }
    
    func reactorForEnterView() -> MemoDetailViewReactor {
        return MemoDetailViewReactor(self.provider)
    }
}
