//
//  Task.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import Foundation
import RxDataSources
import CoreData
import RxCoreData

struct Todo: Equatable, IdentifiableType {
    
    let identity: String
    var contents: String
    var isChecked: Bool
    let date: Date
    
    /// todo create할때 사용
    init(contents: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        
        self.identity = UUID().uuidString
        self.contents = contents
        self.isChecked = false
        self.date = Date()
    }
    
    /// contents 변경시 사용
    init(original: Todo, contents: String) {
        self.identity = original.identity
        self.date = original.date
        self.isChecked = original.isChecked
        
        self.contents = contents
    }
    
    /// isChecked 변경시 사용
    init(original: Todo) {
        self.identity = original.identity
        self.date = original.date
        self.contents = original.contents
        
        self.isChecked = !original.isChecked
    }
    
    /// 날짜 변경시 사용(내일하기, 오늘하기)
    init(original: Todo, date: Date) {
        self.identity = original.identity
        self.contents = original.contents
        self.isChecked = original.isChecked
        
        self.date = date
    }
}

extension Todo: Persistable {
    static var entityName: String {
        return "Todo"
    }
    
    static var primaryAttributeName: String {
        return "identity"
    }
    
    init(entity: NSManagedObject) {
        identity = UUID().uuidString
        contents = entity.value(forKey: "contents") as! String
        isChecked = entity.value(forKey: "isChecked") as! Bool
        date = entity.value(forKey: "date") as! Date
    }
    
    func update(_ entity: NSManagedObject) {
        entity.setValue(UUID().uuidString, forKey: "identity")
        entity.setValue(contents, forKey: "contents")
        entity.setValue(isChecked, forKey: "isChecked")
        entity.setValue(date, forKey: "date")
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
}
