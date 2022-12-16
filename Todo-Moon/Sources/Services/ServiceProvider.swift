//
//  ServiceProvider.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

protocol ServiceProviderType: AnyObject {
    var coreDataService: CoreDataService { get }
    var todoService: TodoService { get }
}

final class ServiceProvider: ServiceProviderType {
    lazy var coreDataService: CoreDataService = CoreDataService(provider: self)
    lazy var todoService: TodoService = TodoService(provider: self)
}
