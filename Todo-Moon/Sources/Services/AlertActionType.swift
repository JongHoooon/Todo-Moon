//
//  AlertActionType.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit
import RxSwift
import URLNavigator

protocol AlertActionType {
  var title: String? { get }
  var style: UIAlertAction.Style { get }
}

extension AlertActionType {
  var style: UIAlertAction.Style {
    return .default
  }
}

protocol AlertServiceType: AnyObject {
  func show<Action: AlertActionType>(
    title: String?,
    message: String?,
    preferredStyle: UIAlertController.Style,
    actions: [Action]
  ) -> Observable<Action>
}

final class AlertService: AlertServiceType {
  
  func show<Action>(
    title: String?,
    message: String?,
    preferredStyle: UIAlertController.Style,
    actions: [Action]
  ) -> RxSwift.Observable<Action> where Action: AlertActionType {
    return Observable.create { observer in
      
      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: preferredStyle
      )
      
      for action in actions {
        let alertAction = UIAlertAction(
          title: action.title,
          style: action.style
        ) { _ in
          observer.onNext(action)
          observer.onCompleted()
        }
        
        alert.addAction(alertAction)
      }
      
      Navigator().present(alert)
      return Disposables.create {
        alert.dismiss(animated: true)
      }
    }
  }
}
