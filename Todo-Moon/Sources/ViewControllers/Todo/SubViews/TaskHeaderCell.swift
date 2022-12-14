//
//  TaskHeaderCell.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import SnapKit
import Then
import UIKit
import ReactorKit

final class TaskHeaderCell: UICollectionReusableView, View {
  
  var disposeBag = DisposeBag()
  
  // MARK: - Constant
  
  struct Icon {
    static let plusImage = UIImage(systemName: "plus.circle")?
      .withTintColor(.label, renderingMode: .alwaysOriginal)
  }
  
  // MARK: - UI
  
  private lazy var plustButton = UIButton().then {
    $0.setTitle("Todo", for: .normal)
    $0.setTitleColor(.label, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16.0)
    $0.setImage(Icon.plusImage, for: .normal)
    $0.semanticContentAttribute = .forceRightToLeft
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4.0,
                                      bottom: 0, right: 0)
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 8.0
  }
  
  // MARK: - Binding
  
  func bind(reactor: TaskHeaderCellReactor) {
    // action
    
    plustButton.rx.tap
      .map { Reactor.Action.plusTask }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Method

extension TaskHeaderCell {
  func configureUI() {
    [
      plustButton
    ].forEach { addSubview($0) }
    
    plustButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(16.0)
      $0.height.equalTo(40.0)
      $0.width.equalTo(80.0)
    }
  }
}
