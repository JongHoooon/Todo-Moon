//
//  MemoViewCell.swift
//  10-2-home
//
//  Created by JongHoon on 2022/10/15.
//

import Then
import SnapKit
import UIKit
import ReactorKit
import RxSwift

final class MemoViewCell: UICollectionViewCell, View {
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16.0, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private lazy var contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14.0, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 2
    }
    
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .quaternaryLabel
    }
    
    // MARK: - Initalizing
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    func bind(reactor: MemoViewCellReactor) {
        
        // state
        
        reactor.state.asObservable().map { $0.memo }
            .subscribe(onNext: { [weak self] memo in
                guard let self = self else { return }
                
                self.titleLabel.text = memo.title
                
                self.contentLabel.text = memo.contents
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Private

private extension MemoViewCell {
    
    func configureLayout() {
        
        [
            titleLabel,
            separatorView,
            contentLabel
        ].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalToSuperview().inset(16.0)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(0.5)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(separatorView.snp.bottom).offset(8.0)
        }
        
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
}
