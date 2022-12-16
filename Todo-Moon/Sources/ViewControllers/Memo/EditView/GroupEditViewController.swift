////
////  GroupEditViewController.swift
////  HongikTimer
////
////  Created by JongHoon on 2022/11/23.
////
//
//import UIKit
//import ReactorKit
//import RxGesture
//
//final class GroupEditViewController: BaseViewController, View {
//    
//    // MARK: - UI
//    
//    private lazy var closeBarButton = UIBarButtonItem().then {
//        $0.image = UIImage(systemName: "xmark")?.withTintColor(.label, renderingMode: .alwaysOriginal)
//    }
//    
//    private lazy var submitBarButton = UIBarButtonItem().then {
//        $0.title = "완료"
//    }
//    
//    private lazy var titleTextField = UITextField().then {
//        $0.placeholder = "그룹 이름"
//        $0.becomeFirstResponder()
//    }
//    
//    private lazy var numberSelectView = NumberSelectView()
//    
//    private lazy var contentTextView = UITextView().then {
//        $0.font = .systemFont(ofSize: 17.0)
//        $0.textColor = .label
//    }
//    
//    private lazy var firstSeparatorView = UIView().then {
//        $0.backgroundColor = .separator
//    }
//    
//    private lazy var secondSeparatorView = UIView().then {
//        $0.backgroundColor = .separator
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureLayout()
//    }
//    
//    // MARK: - Initialize
//    init(_ reactor: GroupEditViewReactor) {
//        super.init()
//        
//        self.reactor = reactor
//        self.titleTextField.text = reactor.initialState.title
//        self.contentTextView.text = reactor.initialState.content
//        
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Binding
//    
//    func bind(reactor: GroupEditViewReactor) {
//        
//        // action
//        
//        closeBarButton.rx.tap
//            .map { Reactor.Action.close }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//        
//        submitBarButton.rx.tap
//            .map { Reactor.Action.submit }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//        
//        let titleText = titleTextField.rx.text.orEmpty
//        let contentText = contentTextView.rx.text.orEmpty
//        
//        Observable.combineLatest(titleText, contentText)
//            .map { Reactor.Action.updateText(title: $0, content: $1)}
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//        
//        // state
//        reactor.state.asObservable().map { $0.isDismissed }
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismiss(animated: true)
//            })
//            .disposed(by: self.disposeBag)
//        
//        reactor.state.asObservable().map { $0.selectNumber }
//            .distinctUntilChanged()
//            .bind(to: numberSelectView.numberLabel.rx.selectedNumber)
//            .disposed(by: self.disposeBag)
//        
//        reactor.state.asObservable().map { $0.canSubmit }
//            .distinctUntilChanged()
//            .bind(to: submitBarButton.rx.isEnabled)
//            .disposed(by: self.disposeBag)
//        
//    }
//}
//
//// MARK: - Method
//
//extension GroupEditViewController {
//    
//    private func configureLayout() {
//        self.view.backgroundColor = .systemBackground
//        
//        self.navigationItem.title = "글쓰기"
//        self.navigationItem.leftBarButtonItem = closeBarButton
//        self.navigationItem.rightBarButtonItem = submitBarButton
//        
//        [
//            titleTextField,
//            firstSeparatorView,
//            numberSelectView,
//            secondSeparatorView,
//            contentTextView
//        ].forEach { view.addSubview($0) }
//        
//        titleTextField.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
//            $0.leading.trailing.equalToSuperview().inset(16.0)
//        }
//        
//        firstSeparatorView.snp.makeConstraints {
//            $0.top.equalTo(titleTextField.snp.bottom).offset(16.0)
//            $0.leading.trailing.equalToSuperview().inset(16.0)
//            $0.height.equalTo(0.5)
//        }
//        
//        numberSelectView.snp.makeConstraints {
//            $0.top.equalTo(firstSeparatorView.snp.bottom).offset(16.0)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(14.0)
//        }
//        
//        secondSeparatorView.snp.makeConstraints {
//            $0.top.equalTo(numberSelectView.snp.bottom).offset(16.0)
//            $0.leading.trailing.equalToSuperview().inset(16.0)
//            $0.height.equalTo(0.5)
//        }
//        
//        contentTextView.snp.makeConstraints {
//            $0.top.equalTo(secondSeparatorView.snp.bottom).offset(16.0)
//            $0.leading.trailing.equalToSuperview().inset(16.0)
//            $0.height.equalTo(300.0)
//        }
//    }
//}
