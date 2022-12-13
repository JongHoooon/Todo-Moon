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

final class TodoViewReactor: Reactor, BaseReactorType {
  
  var disposebag = DisposeBag()
  
  enum Action {
    case load
    case selectedDay(Date)
    case selectedId(String)
    
    case tapToggle
  }
  
  enum Mutation {
    case setTasks([Task])
    case setSelectedDayList(Date)
    case selectedId(String)
    
    case insertSectionItem(IndexPath, TaskListSection.Item, Task)
    case deleteSectionItem(IndexPath)
    case updateSectionItem(IndexPath, TaskListSection.Item)
    case updateCheckedSectionItem(IndexPath, TaskListSection.Item)
    
    case doTomorrow(IndexPath, Task)
    case doToday(IndexPath, Task)
    
    case tapToggle
    
  }
  
  struct State {
    var sections: [TaskListSection]
    
    var tasks: [Task]
    var selectedDay: Date = Date()
    var selectedId: String = ""
    
    var isWeekScope: Bool = true
  }
  
  let provider: ServiceProviderType
  let userInfo: UserInfo
  let initialState: State
  let todoRelay = BehaviorRelay<String>(value: "")
  let checkedCellIdRelay = BehaviorRelay<String>(value: "")
  let dateFormatter = DateFormatter().then {
    $0.dateFormat = "yyyy-MM-dd"
    $0.locale = Locale(identifier: "ko_kr")
    $0.timeZone = TimeZone(identifier: "KST")
  }
  
  // MARK: - Initialize
  
  init(_ provider: ServiceProviderType, userInfo: UserInfo) {
    self.userInfo = userInfo
    self.provider = provider
    self.initialState = State(sections: [], tasks: [])
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .load:
      return self.provider.apiService.getTasks()
        .map { todos in
          let tasks = todos.map { Task(todo: $0) }
          return .setTasks(tasks)
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
            let count = self.currentState.sections[0].items.count
            let indexPath = IndexPath(item: count, section: 0)
            
            return self.provider.apiService.createTodo(
              contents: self.todoRelay.value,
              date: self.currentState.selectedDay
            )
            .map { task in
              let reactor = TaskCellReactor(
                self.provider,
                userInfo: self.userInfo,
                task: task,
                checkRelay: self.checkedCellIdRelay
              )
              
              return .insertSectionItem(indexPath, reactor, task)}
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
      
      let task = currentState.tasks.filter { $0.id == currentState.selectedId }
      guard let taskID = task.first?.taskID else { return .empty() }
      self.provider.apiService.deleteTodo(taskId: taskID)
      
      return .just(.deleteSectionItem(indexPath))
      
    case .edit:
      guard let indexPath = self.indexPath(
        forTaskID: state.selectedId,
        from: state
      ) else { return .empty() }
      
      var task = (currentState.tasks.filter { $0.id == currentState.selectedId })[0]
      task.contents = self.todoRelay.value
      
      let reactor = TaskCellReactor(
        self.provider,
        userInfo: userInfo,
        task: task,
        checkRelay: self.checkedCellIdRelay
      )
      
      guard let taskID = task.taskID else { return .empty() }
      self.provider.apiService.editTodo(contents: self.todoRelay.value, taskId: taskID)
      
      return .just(.updateSectionItem(indexPath, reactor))
      
    case .check:
      guard let indexPath = self.indexPath(forTaskID: checkedCellIdRelay.value, from: state) else { return .empty() }
      var task = state.sections[indexPath].currentState.task
      task.isChecked?.toggle()
      let reactor = TaskCellReactor(
        self.provider,
        userInfo: self.userInfo,
        task: task,
        checkRelay: self.checkedCellIdRelay
      )
      guard let taskID = task.taskID else { return .empty() }
      self.provider.apiService.checkTodo(taskId: taskID)
      return .just(.updateCheckedSectionItem(indexPath, reactor))
      
    case .changeTomorrow:
      guard let indexPath = self.indexPath(
        forTaskID: state.selectedId,
        from: state
      ) else { return .empty() }
      
      let task = currentState.sections[0].items[indexPath.item].currentState.task
      
      self.provider.apiService.deleteTodo(taskId: task.taskID ?? 0 )
      
      let today = Date()
      let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
      
      return self.provider.apiService.createTodo(contents: task.contents ?? "", date: tomorrow ?? Date())
        .map { task in
          
          return .doTomorrow(indexPath, task)
        }
      
    case .changeToday:
      guard let indexPath = self.indexPath(
        forTaskID: state.selectedId,
        from: state
      ) else { return .empty() }
      
      let task = currentState.sections[0].items[indexPath.item].currentState.task
      
      self.provider.apiService.deleteTodo(taskId: task.taskID ?? 0 )
      return self.provider.apiService.createTodo(contents: task.contents ?? "" , date: Date())
        .map { task in
          
          return .doToday(indexPath, task)
        }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    
    switch mutation {
      
    case let .insertSectionItem(indexPath, sectionItem, task):
      state.sections.insert(sectionItem, at: indexPath)
      state.tasks.insert(task, at: state.tasks.count)
      
    case let .setTasks(tasks):
      let currentTasks = tasks.filter { $0.date == dateFormatter.string(from: Date())}
      
      state.tasks = tasks
      let sectionItems = currentTasks.map { TaskCellReactor(
        self.provider,
        userInfo: self.userInfo,
        task: $0,
        checkRelay: self.checkedCellIdRelay
      )}
      let sectionModel = TaskHeaderCellReactor(self.provider, userInfo: self.userInfo)
      let section = TaskListSection(model: sectionModel, items: sectionItems)
      state.sections = [section]
      
    case let .setSelectedDayList(date):
      state.selectedDay = date
      
      let tasks = state.tasks
      let currentTasks = tasks.filter { $0.date == dateFormatter.string(from: date)}
      let sectionItems = currentTasks.map { TaskCellReactor(
        self.provider,
        userInfo: self.userInfo,
        task: $0,
        checkRelay: self.checkedCellIdRelay
      )}
      let sectionModel = TaskHeaderCellReactor(self.provider, userInfo: self.userInfo)
      let section = TaskListSection(model: sectionModel, items: sectionItems)
      state.sections = [section]
      
    case let .selectedId(id):
      state.selectedId = id
      
    case let .deleteSectionItem(indexPath):
      state.sections.remove(at: indexPath)
      state.tasks = state.tasks.filter { $0.id != state.selectedId }
      
    case let .updateSectionItem(indexPath, sectionItem):
      state.sections[indexPath] = sectionItem
      
      if let index = state.tasks.firstIndex(where: { $0.id == state.selectedId }) {
        state.tasks[index].contents = todoRelay.value
      }
      
    case let .updateCheckedSectionItem(indexPath, sectionItem):
      state.sections[indexPath] = sectionItem
      
      if let index = state.tasks.firstIndex(where: { $0.id == checkedCellIdRelay.value }) {
        state.tasks[index].isChecked?.toggle()
      }
    case .tapToggle:
      state.isWeekScope.toggle()
    case let .doTomorrow(indexPath, task):
      
      // 추가
      let count = self.currentState.sections[0].items.count
      let insertIndexPath = IndexPath(item: count, section: 0)
      state.tasks.insert(task, at: state.tasks.count)
      
      // 삭제
      state.tasks = state.tasks.filter { $0.id != state.selectedId }
      state.sections.remove(at: indexPath)
      
    case let .doToday(indexPath, task):
      let count = self.currentState.sections[0].items.count
      let insertIndexPath = IndexPath(item: count, section: 0)
      state.tasks.insert(task, at: state.tasks.count)
      
      state.tasks = state.tasks.filter { $0.id != state.selectedId }
      state.sections.remove(at: indexPath)
    }
    
    return state
  }
}

// MARK: - Method

extension TodoViewReactor {
  
  private func indexPath(forTaskID taskID: String, from state: State) -> IndexPath? {
    let section = 0
    let item = state.sections[section].items.firstIndex { reactor in reactor.currentState.task.id == taskID }
    
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
    
    let task = currentState.sections.first?.items[indexPath.item].currentState.task
    
    return TaskEditViewReactor(
      provider: self.provider,
      userInfo: self.userInfo, task: task!, mode: mode)
  }
  
  private func isToday(day: Date) -> Bool {
    let todayString = self.dateFormatter.string(from: Date())
    let dayStrgin = self.dateFormatter.string(from: day)
    
    if todayString == dayStrgin {
      return true
    } else {
      return false
    }
  }
}
