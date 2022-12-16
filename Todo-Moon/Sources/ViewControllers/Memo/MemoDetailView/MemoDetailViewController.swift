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
    
    // MARK: - Property
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(tapLeftbarButton)
        )
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
    
    @objc func tapEnterButton() {
        print("입장하기")
        
        let alertController = UIAlertController(title: "", message: "가입이 완료됐습니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
