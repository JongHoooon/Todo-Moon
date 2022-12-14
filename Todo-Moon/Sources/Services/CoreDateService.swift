//
//  CoreDateService.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import Foundation
import RxSwift
import RxCoreData
import CoreData
import Then

protocol CoreDataServiceType {
    
    @discardableResult
    func createTodo(content: String) -> Observable<Todo>
    
    @discardableResult
    func fetchTodos() -> Observable<[Todo]>
    
    @discardableResult
    func editTodo(contents: String, todo: Todo) -> Observable<Todo>
    
    @discardableResult
    func deleteTodo(todo: Todo) -> Observable<Todo>
    
    @discardableResult
    func checkTodo(todo: Todo) -> Observable<Todo>
    
    @discardableResult
    func changeDate(todo: Todo, date: Date) -> Observable<Todo>
}

final class CoreDataService: BaseService, CoreDataServiceType {
 
    let modelName: String = "Todo_Moon"
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer = NSPersistentContainer(name: modelName).then {
        $0.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolver error \(error)")
            }
        }
    }
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @discardableResult
    func createTodo(content: String) -> Observable<Todo> {
        let todo = Todo(contents: content)
        
        do {
            _ = try mainContext.rx.update(todo)
            return Observable.just(todo)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func fetchTodos() -> Observable<[Todo]> {
        return mainContext.rx.entities(Todo.self,
                                       sortDescriptors: [NSSortDescriptor(key: "date",
                                                                          ascending: false)])
    }
    
    @discardableResult
    func editTodo(contents: String, todo: Todo) -> Observable<Todo> {
        let editedTodo = Todo(original: todo, contents: contents)
        
        do {
            _ = try mainContext.rx.update(editedTodo)
            return Observable.just(editedTodo)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func checkTodo(todo: Todo) -> Observable<Todo> {
        let editedTodo = Todo(original: todo)
        
        do {
            try mainContext.rx.update(editedTodo)
            return Observable.just(editedTodo)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func deleteTodo(todo: Todo) -> Observable<Todo> {
        do {
            try mainContext.rx.delete(todo)
            
            return Observable.just(todo)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func changeDate(todo: Todo, date: Date) -> Observable<Todo> {
        let editedTodo = Todo(original: todo, date: date)
        
        do {
            try mainContext.rx.update(editedTodo)
            return Observable.just(editedTodo)
        } catch {
            return Observable.error(error)
        }
    }
    
}
