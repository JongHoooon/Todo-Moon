//
//  MemoWriteViewController.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/09.
//

import UIKit
import ReactorKit
import RxGesture

final class MemoWriteViewController: BaseViewController, View {
    
    typealias Reactor = MemoWriteViewReactor
    
    // MARK: - UI
    
    private lazy var closeBarButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "xmark")?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }
    
    private lazy var submitBarButton = UIBarButtonItem().then {
        $0.title = "완료"
    }
    
    private lazy var titleTextField = UITextField().then {
        $0.placeholder = "제목"
    }
    
    private lazy var contentTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 17.0)
        $0.text = "내용을 입력해주세요"
        $0.textColor = .placeholderText
    }
    
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .separator
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    
    // MARK: - Initialize
    init(_ reactor: MemoWriteViewReactor) {
        super.init()
        
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    func bind(reactor: MemoWriteViewReactor) {
        
        // action
        
        closeBarButton.rx.tap
            .map { Reactor.Action.close }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        submitBarButton.rx.tap
            .map { Reactor.Action.submit }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let titleText = titleTextField.rx.text.orEmpty
        let contentText = contentTextView.rx.text.orEmpty
        
        Observable.combineLatest(titleText, contentText)
            .skip(1)
            .map { Reactor.Action.updateText(title: $0, content: $1)}
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // TODO: textField처럼 placeHolder 구현해보기
        contentTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.contentTextView.textColor == .placeholderText {
                    self.contentTextView.text = nil
                    self.contentTextView.textColor = .label
                }
            })
            .disposed(by: self.disposeBag)
        
        contentTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.contentTextView.text == nil || self.contentTextView.text == "" {
                    self.contentTextView.text = "내용을 입력해주세요"
                    self.contentTextView.textColor = .placeholderText
                }
            })
            .disposed(by: self.disposeBag)
        
        // state
        reactor.state.asObservable().map { $0.isDismissed }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(reactor.state.asObservable().map { $0.title },
                                 reactor.state.asObservable().map { $0.content })
            .subscribe { [weak self] title, _ in
                guard let self = self else { return }
                
                if title.isEmpty || self.contentTextView.textColor == .placeholderText {
                    self.submitBarButton.isEnabled = false
                } else {
                    self.submitBarButton.isEnabled = true
                }
            }
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Method

extension MemoWriteViewController {
    
    private func configureLayout() {
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "메모 쓰기"
        self.navigationItem.leftBarButtonItem = closeBarButton
        self.navigationItem.rightBarButtonItem = submitBarButton
        
        [
            titleTextField,
            separatorView,
            contentTextView
        ].forEach { view.addSubview($0) }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(0.5)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(300.0)
        }
    }
}
