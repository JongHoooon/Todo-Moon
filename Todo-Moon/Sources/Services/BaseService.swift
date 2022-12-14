//
//  BaseService.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

class BaseService {
    unowned let provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = provider
    }
}
