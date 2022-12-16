//
//  MemoService.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/17.
//

import Foundation
import UIKit
import RxSwift
import CoreData

enum MemoEvent {
    case edit(memo: Memo)
}

final class MemoService: BaseService {
    let memoEvent = PublishSubject<MemoEvent>()
    
    @discardableResult
    func editMemo(memo: Memo) -> Observable<Bool> {
        self.memoEvent.onNext(.edit(memo: memo))
        return .just(true)
    }
}
