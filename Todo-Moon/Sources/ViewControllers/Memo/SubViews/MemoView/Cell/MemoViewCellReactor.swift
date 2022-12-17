//
//  MemoViewCellReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/06.
//

import ReactorKit
import RxCocoa
import RxSwift

final class MemoViewCellReactor: Reactor {
    
    
    typealias Action = NoAction
    
    struct State {
        let memo: Memo
    }
    
    var provider: ServiceProviderType
    var initialState: State
    
    init(memo: Memo, provider: ServiceProviderType) {
        self.initialState = State(memo: memo)
        self.provider = provider
    }
}
