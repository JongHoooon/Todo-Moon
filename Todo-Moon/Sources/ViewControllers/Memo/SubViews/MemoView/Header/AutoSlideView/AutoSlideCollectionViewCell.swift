//
//  AutoSlideCell.swift
//  10-2-home
//
//  Created by JongHoon on 2022/10/14.
//

import Then
import SnapKit
import UIKit

final class AutoSlideCollectionViewCell: UICollectionViewCell {
    
    private lazy var contentLabel = UILabel().then {
        $0.font = .systemFont(
            ofSize: 12.0,
            weight: .regular
        )
        $0.textColor = .black
        $0.numberOfLines = 1
    }

// MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Internal

extension AutoSlideCollectionViewCell {
    func configureCell(_ content: String) {
        contentLabel.text = content + " Hype Chick🔥👨‍💻"
    }
}

// MARK: - Private

private extension AutoSlideCollectionViewCell {
    func configureLayout() {
        
        backgroundColor = UIColor.init(rgb: 0xDBF0FF)
        
        addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
