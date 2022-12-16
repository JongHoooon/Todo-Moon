//
//  NumberSelectView.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/10.
//

import UIKit
import Then
import SnapKit

final class NumberSelectView: UIView {
  
  // MARK: - UI
  
  lazy var numberLabel = UILabel().then {
    $0.textColor = .label
  }
  
  private lazy var chevronImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "chevron.right")?.withTintColor(.label, renderingMode: .alwaysOriginal)
  }
  
  init() {
    super.init(frame: .zero)
    
    [
      numberLabel,
      chevronImageView
    ].forEach { addSubview($0) }
    
    numberLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(16.0)
      $0.centerY.equalToSuperview()
    }
    
    chevronImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16.0)
      $0.height.width.equalTo(16.0)
      $0.centerY.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
