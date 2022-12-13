//
//  TaskCell.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit

import ReactorKit
import SnapKit
import Then

final class TaskCell: UICollectionViewCell, View {
  
  var disposeBag = DisposeBag()
  
  private struct Icon {
    static let squareIcon = UIImage(systemName: "square")
    static let checkSquareIcon = UIImage(systemName: "checkmark.square")
    static let editIcon = UIImage(systemName: "ellipsis")?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
  }
  
  private lazy var checkButton = UIButton().then {
    $0.setImage(Icon.squareIcon, for: .normal)
    $0.tintColor = .label
    $0.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
  }
  
  lazy var textField = UITextField().then {
    $0.placeholder = "입력"
    $0.delegate = self
  }
  
  var isChecked: Bool = false
  
  private lazy var editImageView  = UIImageView().then {
    $0.image = Icon.editIcon
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .systemGray2
  }
  
  // MARK: - Initialize
  
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Binding
  
  func bind(reactor: TaskCellReactor) {
    
    // action
    
    checkButton.rx.tap
      .map { Reactor.Action.tapBox }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // state
    reactor.state.asObservable().map { $0.task }
      .subscribe(onNext: { [weak self] task in
        guard let self = self else { return }
        
        self.textField.text = task.contents
        let icon: UIImage? = task.isChecked ?? false ? Icon.checkSquareIcon : Icon.squareIcon
        self.checkButton.setImage(icon, for: .normal)
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable().map { $0.isEnabled }
      .bind(to: textField.rx.isEnabled)
      .disposed(by: self.disposeBag)
  }
}

// MARK: - TextField

extension TaskCell: UITextFieldDelegate {
  
  //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  //
  //        if isEditMode == false {
  //            taskVM = TaskViewModel(task: Task(
  //                taskId: 0,
  //                userId: 0,
  //                contents: textField.text ?? "",
  //                isChecked: false)
  //            )
  //            textField.isEnabled = false
  //            if textField.text?.isEmpty == false {
  //                guard let taskVM = taskVM else { return false }
  //                textFieldNotEmptyCompletion?(taskVM)
  //            } else {
  //                textFieldEmptyCompletion?()
  //            }
  //        } else {
  //            guard let task = taskVM?.task else { return false }
  //            taskVM = TaskViewModel(task: Task(
  //                taskId: task.taskId,
  //                userId: task.userId,
  //                contents: textField.text ?? "",
  //                isChecked: task.isChecked ?? false)
  //            )
  //            guard let taskVM = taskVM else { return false }
  //            textField.isEnabled = false
  //            isEditMode = false
  //            textFieldEditCompletion?(taskVM, indexPath ?? [])
  //        }
  //
  //        return true
  //    }
}

// MARK: - Private

private extension TaskCell {
  
  func setupLayout() {
    
    [
      checkButton,
      textField,
      editImageView
    ].forEach { addSubview($0) }
    
    checkButton.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(8.0)
      $0.leading.equalToSuperview().inset(16.0)
      $0.height.width.equalTo(32.0)
      $0.centerY.equalToSuperview()
    }
    
    textField.snp.makeConstraints {
      $0.leading.equalTo(checkButton.snp.trailing).offset(8.0)
      $0.height.equalTo(16.0)
      $0.trailing.equalTo(editImageView.snp.leading).offset(-16.0)
      $0.centerY.equalTo(checkButton)
    }
    
    editImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(16.0)
      $0.width.equalTo(20.0)
    }
  }
  
  // MARK: - selector
  
  @objc func toggleButton() {
    if isChecked == false {
      checkButton.setImage(Icon.checkSquareIcon, for: .normal)
    } else {
      checkButton.setImage(Icon.squareIcon, for: .normal)
    }
    isChecked.toggle()
  }
  
  // TODO: button 클릭시 viewModelList 업데이트, 마지막 todo 클릭시 한번만 바뀜
}
