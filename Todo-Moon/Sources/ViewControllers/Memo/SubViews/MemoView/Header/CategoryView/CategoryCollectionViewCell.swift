//
//  CategoryCell.swift
//  10-2-home
//
//  Created by JongHoon on 2022/10/15.
//

import SnapKit
import Then
import UIKit
    
final class CategoryCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 30.0
        $0.clipsToBounds = true
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12.0, weight: .light)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
        titleLabel.text = "타이틀"
        titleImageView.image = UIImage(named: "profileDefault")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Internal

extension CategoryCollectionViewCell {
    func configureCell(_ image: UIImage, _ text: String) {
        titleImageView.image = image
        titleLabel.text = text
    }
}


// MARK: - Private

private extension CategoryCollectionViewCell {
    
    func configureLayout() {
        [
            titleImageView,
            titleLabel
        ].forEach { addSubview($0) }
        
        titleImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.width.height.equalTo(60.0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleImageView.snp.bottom).offset(8.0)
            $0.centerX.equalTo(titleImageView)
        }
    }
}
