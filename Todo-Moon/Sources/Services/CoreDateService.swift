//
//  CoreDateService.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import Foundation
import RxSwift
import CoreData
import Then

protocol CoreDataServiceType {
    
    // MARK: - Todo
    
    @discardableResult
    func createTodo(content: String, date: Date) -> Observable<Todo>

    @discardableResult
    func fetchTodos() -> Observable<[Todo]>

    @discardableResult
    func editTodoContents(contents: String, todo: Todo) -> Observable<Todo>

    @discardableResult
    func deleteTodo(todo: Todo) -> Observable<Todo>

    @discardableResult
    func checkTodo(todo: Todo) -> Observable<Todo>

    @discardableResult
    func changeDate(todo: Todo, date: Date) -> Observable<Todo>
    
    // MARK: - Memo
    
    @discardableResult
    func createMemo(title: String, contents: String) -> Observable<Memo>
    
    @discardableResult
    func fetchMemos() -> Observable<[Memo]>
    
    @discardableResult
    func editMemo(memo: Memo, title: String, contents: String) -> Observable<Memo>
    
    @discardableResult
    func deleteMemo(memo: Memo) -> Observable<Memo>

}

final class CoreDataService: BaseService, CoreDataServiceType {
    
    // MARK: - Todo
    
    lazy var persistentContainer = NSPersistentContainer(name: "Todo_Moon").then {
        $0.loadPersistentStores { description, error in
            if let error = error {
                fatalError("💬 failed to initialize Core Data \(error)")
            }
            
            _ = description
        }
    }
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @discardableResult
    func createTodo(content: String, date: Date) -> RxSwift.Observable<Todo> {
        let todo = Todo(context: mainContext)
        todo.contents = content
        todo.date = date
        todo.id = UUID().uuidString
        
        do {
            try mainContext.save()
            return Observable.just(todo)
        } catch {
            print("💬 Failed to save a todo \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func fetchTodos() -> Observable<[Todo]> {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        do {
            let todos = try mainContext.fetch(fetchRequest)
            return Observable.just(todos)
        } catch {
            print("💬 todos fetch 실패")
            return Observable.just([])
        }
    }
    
    @discardableResult
    func editTodoContents(contents: String, todo: Todo) -> Observable<Todo> {
        todo.contents = contents
        
        do {
            try mainContext.save()
            return Observable.just(todo)
        } catch {
            mainContext.rollback()
            print("💬 todo contnents 변경 실패! \n \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func deleteTodo(todo: Todo) -> Observable<Todo> {
        mainContext.delete(todo)
        
        do {
            try mainContext.save()
            return Observable.just(todo)
        } catch {
            mainContext.rollback()
            print("💬 todo 삭제 실패! \n \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func checkTodo(todo: Todo) -> Observable<Todo> {
        
        do {
            try mainContext.save()
            print(todo.isChecked)
            return Observable.just(todo)
        } catch {
            mainContext.rollback()
            print("💬 todo 체크 실패! \n \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func changeDate(todo: Todo, date: Date) -> Observable<Todo> {
        todo.date = date
        
        do {
            try mainContext.save()
            return Observable.just(todo)
        } catch {
            mainContext.rollback()
            print("💬 todo 날짜 변경 실패 \n \(error)")
            return Observable.error(error)
        }
    }
    
    // MARK: - Memo
    
    @discardableResult
    func createMemo(title: String, contents: String) -> Observable<Memo> {
        let memo = Memo(context: mainContext)
        memo.title = title
        memo.contents = contents
        
        do {
            try mainContext.save()
            return Observable.just(memo)
        } catch {
            print("💬 memo 저장 실패")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func fetchMemos() -> Observable<[Memo]> {
        let fetchRequest: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            let memos = try mainContext.fetch(fetchRequest)
            return .just(memos)
        } catch {
            print("DEBUG memos fetch 실패")
            return .just([])
        }
    }
    
    @discardableResult
    func editMemo(memo: Memo, title: String, contents: String) -> Observable<Memo> {
        memo.title = title
        memo.contents = contents
        
        do {
            try mainContext.save()
            return .just(memo)
        } catch {
            mainContext.rollback()
            print("DEBUG memo 편집 실패")
            return .error(error)
        }
    }
    
    @discardableResult
    func deleteMemo(memo: Memo) -> Observable<Memo> {
        mainContext.delete(memo)
        
        do {
            try mainContext.save()
            return .just(memo)
        } catch {
            mainContext.rollback()
            print("DEBUG memo 삭제 실패")
            return .error(error)
        }
    }
}
