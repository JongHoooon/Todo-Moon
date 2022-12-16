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
}
