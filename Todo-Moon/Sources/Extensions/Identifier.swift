//
//  Identifier.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
