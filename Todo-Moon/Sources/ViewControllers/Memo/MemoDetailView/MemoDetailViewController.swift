//
//  MemoDetailViewController.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/11/02.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class MemoDetailViewController: BaseViewController, View {
    
    // MARK: - UI
    
    private lazy var  titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24.0, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }
    
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .quaternaryLabel
    }
    
    private lazy var contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12.0, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        configureNavigateion()
        
    }
    
    // MARK: - Initialize
    init(reactor: MemoDetailViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    func bind(reactor: MemoDetailViewReactor) {
        
        // state
        
        reactor.state.asObservable().map { $0.memo }
            .subscribe(onNext: { [weak self] memo in
                guard let self = self,
                      let memo = memo else { return }
                
                self.titleLabel.text = memo.title ?? "club name"
                
                self.contentLabel.text = memo.contents ?? ""
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Method

private extension MemoDetailViewController {
    
    func configureNavigateion() {
        navigationItem.title = "Memo 🌕"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(tapLeftbarButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(tapMenuButton))
    }
    
    func configureLayout() {
        
        view.backgroundColor = .systemBackground
        
        [
            titleLabel,
            separatorView,
            contentLabel
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(0.5)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(separatorView.snp.bottom).offset(16.0)
        }
    }
    
    // MARK: - Selector
    
    @objc func tapLeftbarButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapMenuButton() {
        
        let confirmAlertController = UIAlertController(title: "메모 삭제",
                                                       message: "정말로 메모를 삭제하시겠습니까?",
                                                       preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel)
        
        let confirmAction = UIAlertAction(title: "확인",
                                          style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            guard let memo = self.reactor?.currentState.memo else { return }
            self.reactor?.provider.coreDataService.deleteMemo(memo: memo)
            self.navigationController?.popViewController(animated: true)
        }
        
        [
            confirmAction,
            cancelAction
        ].forEach { confirmAlertController.addAction($0) }
        
        let menuAlertController = UIAlertController(title: "그룹 수정 / 삭제",
                                                    message: nil,
                                                    preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정",
                                       style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let provider = self.reactor?.provider else { return }
            guard let memo = self.reactor?.currentState.memo else { return }
            let vc = MemoEditViewController(MemoEditViewReactor(provider: provider, memo: memo))
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: "삭제",
                                         style: .destructive) { _ in
            
            self.present(confirmAlertController, animated: true)
        }
        
        [
            editAction,
            deleteAction,
            cancelAction
        ].forEach { menuAlertController.addAction($0) }
        self.present(menuAlertController, animated: true)
    }
}
