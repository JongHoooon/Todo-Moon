//
//  TodoService.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit
import RxSwift

enum HeaderEvent {
  case create
}

enum EditEvent {
  case delete
  case edit
  case check
  case changeTomorrow
  case changeToday
}

final class TodoService: BaseService {
    
  let headerEvent = PublishSubject<HeaderEvent>()
  let editEvent = PublishSubject<EditEvent>()
  
  // MARK: - Header Event
  func tapCreateButton() -> Observable<Void> {
    self.headerEvent.onNext(.create)
    return .empty()
  }
  
  // MARK: - Edit Event
  func tapEditButton() -> Observable<Bool> {
    self.editEvent.onNext(.edit)
    return .just(true)
  }
  
  func tapDeleteButton() -> Observable<Bool> {
    self.editEvent.onNext(.delete)
    return .just(true)
  }
  
  func tapCheckButton() -> Observable<Bool> {
    self.editEvent.onNext(.check)
    return .just(true)
  }
  
  func tapChangeTomorrow() -> Observable<Bool> {
    self.editEvent.onNext(.changeTomorrow)
    return .just(true)
  }
  
  func tapChangeToday() -> Observable<Bool> {
    self.editEvent.onNext(.changeToday)
    return .just(true)
  }
}
