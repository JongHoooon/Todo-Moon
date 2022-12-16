//
//  TaskEditViewReactor.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/15.
//

import ReactorKit
import RxCocoa
import RxSwift
import URLNavigator

enum TaskEditMode {
    case today
    case notToday
}

final class TaskEditViewReactor: Reactor {
    
    enum Action {
        case edit
        case delete
        case tapChangeButton
    }
    
    enum Mutation {
        case dismiss
        case empty
    }
    
    struct State {
        let todo: Todo
        var isDismissed: Bool = false
        var changeButtonTitle: String
    }
    
    let provider: ServiceProviderType
    let initialState: State
    var todoRelay = BehaviorRelay<String>(value: "")
    var disposebag = DisposeBag()
    let taskEditMode: TaskEditMode
    
    // MARK: - Init
    
    init(provider: ServiceProviderType,
         todo: Todo,
         mode: TaskEditMode) {
        var changeButtonTitle: String {
            switch mode {
            case .today:
                return "내일 하기"
            case .notToday:
                return "오늘 하기"
            }
        }
        
        self.provider = provider
        self.taskEditMode = mode
        self.initialState = State(todo: todo,
                                  changeButtonTitle: changeButtonTitle)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .delete:
            return self.provider.todoService.tapDeleteButton()
                .map { _ in .dismiss }
            
        case .edit:
            let observer = Observable.create { observer in
                let actions: [TaskEditAlertAction] = [.leave, .submit]
                let alert = UIAlertController(title: "Todo", message: nil, preferredStyle: .alert)
                for action in actions {
                    let alerAction = UIAlertAction(title: action.title, style: action.style) { _ in
                        observer.onNext(action)
                        observer.onCompleted()
                    }
                    alert.addAction(alerAction)
                }
                alert.addTextField { [weak self] textField in
                    guard let self = self else { return }
                    textField.text = self.currentState.todo.contents
                    
                    textField.rx.text.orEmpty.subscribe { [weak self] in
                        guard let self = self else { return }
                        self.todoRelay.accept($0)
                    }
                    .disposed(by: self.disposebag)
                }
                Navigator().present(alert)
                return Disposables.create {
                    alert.dismiss(animated: true)
                }
            }
            
            // TODO: weak self?
            return observer
                .flatMap { alertAction -> Observable<Mutation> in
                    switch alertAction {
                    case .leave:
                        return .empty()
                    case .submit:
                        return self.provider.todoService.tapEditButton()
                            .map { _ in .dismiss }
                    }
                }
            
        case .tapChangeButton:
            switch taskEditMode {
            case .today:
                return self.provider.todoService.tapChangeTomorrow()
                    .map { _ in .dismiss }
            case .notToday:
                return self.provider.todoService.tapChangeToday()
                    .map { _ in .dismiss }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
        case .dismiss:
            state.isDismissed = true
            
        case .empty:
            return state
        }
        
        return state
    }
}
