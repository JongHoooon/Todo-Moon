//
//  TodoViewReactor.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources
import URLNavigator

typealias TaskListSection = SectionModel<TaskHeaderCellReactor, TaskCellReactor>

enum TaskEditAlertAction: AlertActionType {
    case leave
    case submit
    
    var title: String? {
        switch self {
        case .leave: return "취소"
        case .submit: return "확인"
        }
    }
    
    var style: UIAlertAction.Style {
        switch self {
        case .leave: return .cancel
        case .submit: return .default
        }
    }
}

final class TodoViewReactor: Reactor {
    
    var disposebag = DisposeBag()
    
    enum Action {
        case load
        case selectedDay(Date)
        case selectedId(String)
        
        case tapToggle
    }
    
    enum Mutation {
        case setTodos([Todo])
        case setSelectedDayList(Date)
        case selectedId(String)
        
        case insertSectionItem(IndexPath, TaskListSection.Item, Todo)
        case deleteSectionItem(IndexPath)
        case updateSectionItem(IndexPath, TaskListSection.Item)
        case updateCheckedSectionItem(IndexPath, TaskListSection.Item)
        
        case doTomorrow(IndexPath, Todo)
        case doToday(IndexPath, Todo)
        
        case tapToggle
        
    }
    
    struct State {
        var sections: [TaskListSection]
        
        var todos: [Todo]
        var selectedDay: Date = Date()
        var selectedId: String = ""
        
        var isWeekScope: Bool = true
    }
    
    let provider: ServiceProviderType
    let initialState: State
    let todoRelay = BehaviorRelay<String>(value: "")
    let checkedCellIdRelay = BehaviorRelay<String>(value: "")
    
    // MARK: - Initialize
    
    init(_ provider: ServiceProviderType) {
        self.provider = provider
        self.initialState = State(sections: [], todos: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return self.provider.coreDataService.fetchTodos()
                .map { todos in
                    return .setTodos(todos)
                }
            
        case let .selectedDay(date):
            return .just(.setSelectedDayList(date))
            
        case let .selectedId(id):
            return .just(.selectedId(id))
            
        case .tapToggle:
            return .just(.tapToggle)
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        
        let headerEventMutation = self.provider.todoService.headerEvent
            .flatMap { [weak self] headerEvent -> Observable<Mutation> in
                self?.mutate(headerEvent: headerEvent) ?? .empty()
            }
        
        let taskEditEventMutation = self.provider.todoService.editEvent
            .flatMap { [weak self] editEvent -> Observable<Mutation> in
                self?.mutate(editEvent: editEvent) ?? .empty()
            }
        
        return Observable.of(mutation, headerEventMutation, taskEditEventMutation).merge()
    }
    
    func mutate(headerEvent: HeaderEvent) -> Observable<Mutation> {
        switch headerEvent {
        case .create:
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
                alert.addTextField { textField in
                    textField.placeholder = "할일을 입력하세요!"
                    
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
                        
                        guard self.todoRelay.value.isEmpty == false else { return .empty() }
                        
                        let count = self.currentState.sections[0].items.count
                        let indexPath = IndexPath(item: count, section: 0)
                        
                        return self.provider.coreDataService.createTodo(content: self.todoRelay.value, date: self.currentState.selectedDay)
                            .map { todo in
                                let reactor = TaskCellReactor(self.provider,
                                                              todo: todo,
                                                              checkRelay: self.checkedCellIdRelay)
                                return .insertSectionItem(indexPath, reactor, todo)
                            }
                    }
                }
        }
    }
    
    func mutate(editEvent: EditEvent) -> Observable<Mutation> {
        let state = self.currentState
        
        switch editEvent {
        case .delete:
            guard let indexPath = self.indexPath(
                forTaskID: state.selectedId,
                from: state
            ) else { return .empty() }
            
            guard let todo = (currentState.todos.first { $0.id == currentState.selectedId }) else { return .empty() }
            self.provider.coreDataService.deleteTodo(todo: todo)
            
            return .just(.deleteSectionItem(indexPath))
            
        case .edit:
            guard let indexPath = self.indexPath(
                forTaskID: state.selectedId,
                from: state
            ) else { return .empty() }
            
            guard let todo = (currentState.todos.first { $0.id == currentState.selectedId }) else { return .empty() }
            todo.contents = self.todoRelay.value
            
            let reactor = TaskCellReactor(
                self.provider,
                todo: todo,
                checkRelay: self.checkedCellIdRelay
            )
            
            self.provider.coreDataService.editTodoContents(contents: self.todoRelay.value, todo: todo)
            return .just(.updateSectionItem(indexPath, reactor))
            
        case .check:
            guard let indexPath = self.indexPath(forTaskID: checkedCellIdRelay.value, from: state) else { return .empty() }
            
            var todo = state.sections[indexPath].currentState.todo
            todo.isChecked.toggle()
            
            let reactor = TaskCellReactor(
                self.provider,
                todo: todo,
                checkRelay: self.checkedCellIdRelay
            )
            
            self.provider.coreDataService.checkTodo(todo: todo)
            return .just(.updateCheckedSectionItem(indexPath, reactor))
            
        case .changeTomorrow:
            guard let indexPath = self.indexPath(
                forTaskID: state.selectedId,
                from: state
            ) else { return .empty() }
            
            guard let todo = (currentState.todos.first { $0.id == currentState.selectedId }) else { return .empty() }
            
            let today = Date()
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return .empty() }

            
            return self.provider.coreDataService.changeDate(todo: todo, date: tomorrow)
                .map { todo in
                    return .doTomorrow(indexPath, todo)
                }
            
        case .changeToday:
            guard let indexPath = self.indexPath(
                forTaskID: state.selectedId,
                from: state
            ) else { return .empty() }
            
            guard let todo = (currentState.todos.first { $0.id == currentState.selectedId }) else { return .empty() }
            
            return self.provider.coreDataService.changeDate(todo: todo, date: Date())
                .map { todo in
                    return .doToday(indexPath, todo)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
            
        case let .insertSectionItem(indexPath, sectionItem, task):
            state.sections.insert(sectionItem, at: indexPath)
            state.todos.insert(task, at: state.todos.count)
            
        case let .setTodos(todos):
            let currentTasks = todos.filter { $0.date?.asFormattedString() == Date().asFormattedString()}
            
            state.todos = todos
            let sectionItems = currentTasks.map { TaskCellReactor(
                self.provider,
                todo: $0,
                checkRelay: self.checkedCellIdRelay
            )}
            let sectionModel = TaskHeaderCellReactor(self.provider)
            let section = TaskListSection(model: sectionModel, items: sectionItems)
            state.sections = [section]
            
        case let .setSelectedDayList(date):
            state.selectedDay = date
            
            let todos = state.todos
            let currentTasks = todos.filter { $0.date?.asFormattedString() == date.asFormattedString() }
            let sectionItems = currentTasks.map { TaskCellReactor(
                self.provider,
                todo: $0,
                checkRelay: self.checkedCellIdRelay
            )}
            let sectionModel = TaskHeaderCellReactor(self.provider)
            let section = TaskListSection(model: sectionModel, items: sectionItems)
            state.sections = [section]
            
        case let .selectedId(id):
            state.selectedId = id
            
        case let .deleteSectionItem(indexPath):
            state.sections.remove(at: indexPath)
            state.todos = state.todos.filter { $0.id != state.selectedId }
            
        case let .updateSectionItem(indexPath, sectionItem):
            state.sections[indexPath] = sectionItem
            
            if let index = state.todos.firstIndex(where: { $0.id == state.selectedId }) {
                state.todos[index].contents = todoRelay.value
            }
            
        case let .updateCheckedSectionItem(indexPath, sectionItem):
            state.sections[indexPath] = sectionItem
            
//            if let index = state.todos.firstIndex(where: { $0.id == checkedCellIdRelay.value }) {
//            }
            
        case .tapToggle:
            state.isWeekScope.toggle()
        case let .doTomorrow(indexPath, todo):
            
            // 삭제
            state.todos = state.todos.filter { $0.id != state.selectedId }
            state.sections.remove(at: indexPath)
            
            // 추가
            state.todos.insert(todo, at: state.todos.count)
            
        case let .doToday(indexPath, todo):
            state.todos = state.todos.filter { $0.id != state.selectedId }
            state.sections.remove(at: indexPath)
            
            state.todos.insert(todo, at: state.todos.endIndex)
            
        }
        
        return state
    }
}

// MARK: - Method

extension TodoViewReactor {
    
    private func indexPath(forTaskID taskID: String, from state: State) -> IndexPath? {
        let section = 0
        let item = state.sections[section].items.firstIndex { reactor in reactor.currentState.todo.id == taskID }
        
        if let item = item {
            return IndexPath(item: item, section: section)
        } else {
            return nil
        }
    }
    
    func reactorForTaskEdit(indexPath: IndexPath) -> TaskEditViewReactor {
        var mode: TaskEditMode {
            if isToday(day: currentState.selectedDay) {
                return .today
            } else {
                return .notToday
            }
        }
        
        let todo = currentState.sections.first?.items[indexPath.item].currentState.todo
        
        return TaskEditViewReactor(provider: self.provider,
                                   todo: todo!,
                                   mode: mode)
    }
    
    private func isToday(day: Date) -> Bool {
        let todayString = Date().asFormattedString()
        let dayStrgin = day.asFormattedString()
        
        if todayString == dayStrgin {
            return true
        } else {
            return false
        }
    }
}
