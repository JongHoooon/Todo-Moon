//
//  UIColor+Extension.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import Foundation

import UIKit

extension UIColor {
    static let defaultTintColor = UIColor.init(rgb: 0x364F6B)
    
}

extension UIColor {
  convenience init(red: Int,
                   green: Int,
                   blue: Int,
                   a: Int = 0xFF) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: CGFloat(a) / 255.0
    )
  }
  
  /// HEX 변환
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
  
  /// HEX 변환 with alpha
  convenience init(argb: Int) {
    self.init(
      red: (argb >> 16) & 0xFF,
      green: (argb >> 8) & 0xFF,
      blue: argb & 0xFF,
      a: (argb >> 24) & 0xFF
    )
  }
}
