//
//  TaskEditView.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/10/11.
//

import UIKit
import Then
import ReactorKit

final class TaskEditViewController: BaseViewController, View {
    
    // MARK: - Constant
    
    private struct Icon {
        static let pencilIcon = UIImage(named: "pencil")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        static let trashIcon = UIImage(named: "trashCan")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        static let rightArrow = UIImage(systemName: "arrowshape.turn.up.right.circle")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        static let downArrow = UIImage(systemName: "arrow.down.circle")?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }
    
    // MARK: - Property
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    // MARK: - UI
    
    private lazy var sliderIndicator = UIView().then {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 2
    }
    
    private lazy var todoLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16.0)
        $0.textColor = .label
        $0.textAlignment = .center
    }
    
    private lazy var editButton = UIButton().then {
        $0.backgroundColor = .systemGray6
        $0.setTitle("수정", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.setImage(Icon.pencilIcon, for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        $0.layer.cornerRadius = 8.0
    }
    private lazy var deleteButton = UIButton().then {
        $0.backgroundColor = .systemGray6
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.setImage(Icon.trashIcon, for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        $0.layer.cornerRadius = 8.0
    }
    
    private lazy var changeDayButton = UIButton().then {
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = .clear
        $0.setTitleColor(.label, for: .normal)
        $0.setImage(Icon.rightArrow, for: .normal)
        //        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .separator
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setGesture()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    // MARK: - Init
    
    init(_ reactor: TaskEditViewReactor) {
        super.init()
        
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    func bind(reactor: TaskEditViewReactor) {
        
        // action
        deleteButton.rx.tap
            .map { Reactor.Action.delete }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        editButton.rx.tap
            .map { Reactor.Action.edit }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        changeDayButton.rx.tap
            .map { Reactor.Action.tapChangeButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // state
        reactor.state.asObservable().map { $0.todo }
            .subscribe(onNext: { [weak self] todo in
                self?.todoLabel.text = todo.contents
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.asObservable().map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.asObservable().map { $0.changeButtonTitle }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.changeDayButton.setTitle(title, for: .normal)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Private

private extension TaskEditViewController {
    func setupLayout() {
        
        //    var config1 = UIButton.Configuration.filled()
        //    config1.baseBackgroundColor = .systemGray4
        //    config1.baseForegroundColor = .label
        //
        //    config1.imagePlacement = .top
        //    config1.imagePadding = 4.0
        //    config1.titlePadding = 4.0
        //
        //    editButton.configuration = config1
        //    editButton.configuration?.title = "수정"
        //    editButton.configuration?.image = Icon.pencilIcon
        //
        //    deleteButton.configuration = config1
        //    deleteButton.configuration?.title = "삭제"
        //    deleteButton.configuration?.image = Icon.trashIcon
        //
        //    var config2 = UIButton.Configuration.plain()
        //    config2.baseBackgroundColor = .clear
        //    config2.baseForegroundColor = .label
        //    config2.imagePlacement = .leading
        //    config2.contentInsets = NSDirectionalEdgeInsets(top: 4.0, leading: 0, bottom: 4.0, trailing: 4.0)
        //    config2.imagePadding = 8.0
        //
        //    changeDayButton.configuration = config2
        ////    changeDayButton.configuration?.title = "내일 아님 오늘 하기"
        //    changeDayButton.configuration?.image = Icon.rightArrow
        
        view.backgroundColor = .systemBackground
        
        let buttonStackView = UIStackView(
            arrangedSubviews: [
                editButton,
                deleteButton
            ]
        ).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 8.0
        }
        
        [
            sliderIndicator,
            todoLabel,
            buttonStackView,
            changeDayButton,
            separatorView
        ].forEach { view.addSubview($0) }
        
        sliderIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16.0)
            $0.width.equalTo(40.0)
            $0.height.equalTo(4.0)
        }
        
        todoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(sliderIndicator.snp.bottom).offset(16.0)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(todoLabel.snp.bottom).offset(16.0)
            $0.leading.trailing.equalTo(todoLabel)
            $0.height.equalTo(64.0)
        }
        
        changeDayButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16.0)
            $0.leading.trailing.equalTo(todoLabel)
            $0.height.equalTo(32.0)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(changeDayButton.snp.bottom)
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalTo(todoLabel)
        }
    }
    
    func setGesture() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(panGestureRecognizerAction)
        )
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Selector
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
