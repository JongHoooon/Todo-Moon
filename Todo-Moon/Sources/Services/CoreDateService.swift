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
}

final class CoreDataService: BaseService, CoreDataServiceType {
    
    lazy var todoPersistentContainer = NSPersistentContainer(name: "Todo").then {
        $0.loadPersistentStores { description, error in
            if let error = error {
                fatalError("DEBUG failed to initialize Core Data \(error)")
            }
            
            _ = description
        }
    }
    
    private var todoMainContext: NSManagedObjectContext {
        return todoPersistentContainer.viewContext
    }
    
    @discardableResult
    func createTodo(content: String, date: Date) -> RxSwift.Observable<Todo> {
        let todo = Todo(context: todoMainContext)
        todo.contents = content
        todo.date = date
        
        do {
            try todoMainContext.save()
            return Observable.just(todo)
        } catch {
            print("DEBUG Failed to dave a todo \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func fetchTodos() -> Observable<[Todo]> {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        do {
            let todos = try todoMainContext.fetch(fetchRequest)
            return Observable.just(todos)
        } catch {
            return Observable.just([])
        }
    }
    
    @discardableResult
    func editTodoContents(contents: String, todo: Todo) -> Observable<Todo> {
        todo.contents = contents
        
        do {
            try todoMainContext.save()
            return Observable.just(todo)
        } catch {
            todoMainContext.rollback()
            print("DEBUG todo contnents 변경 실패! \n \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func deleteTodo(todo: Todo) -> Observable<Todo> {
        todoMainContext.delete(todo)
        
        do {
            try todoMainContext.save()
            return Observable.just(todo)
        } catch {
            todoMainContext.rollback()
            print("DEBUG todo 삭제 실패! \n \(error)")
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func checkTodo(todo: Todo) -> Observable<Todo> {
    
        do {
            try todoMainContext.save()
            return Observable.just(todo)
        } catch {
            todoMainContext.rollback()
            print("DEBUG todo 체크 실패! \n \(error)")
            return Observable.error(error)
        }
    }

    @discardableResult
    func changeDate(todo: Todo, date: Date) -> Observable<Todo> {
        todo.date = date
        
        do {
            try todoMainContext.save()
            return Observable.just(todo)
        } catch {
            todoMainContext.rollback()
            print("DEBUG todo 날짜 변경 실패 \n \(error)")
            return Observable.error(error)
        }
    }
}
