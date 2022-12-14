//
//  UIView+Extension.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner,
                      radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

