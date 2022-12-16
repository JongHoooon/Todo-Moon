//
//  Date+Extension.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/16.
//

import Foundation

extension Date {
    
    func asFormattedString() -> String {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
            $0.locale = Locale(identifier: "ko_kr")
            $0.timeZone = TimeZone(identifier: "KST")
        }
        return dateFormatter.string(from: self)
    }
    
    
    
}
