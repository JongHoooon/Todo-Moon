//
//  AutoSlideView.swift
//  10-2-home
//
//  Created by JongHoon on 2022/10/14.
//

import Then
import SnapKit
import UIKit

final class AutoSlideView: UIView {
    
    var nowPage: Int = 0
    
    private lazy var autoSlideTexts: [String] = [
        "오늘도",
        "주말에도",
        "심심할떄",
        "자기 전에"
    ]
    
    private lazy var autoSlideCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        layout.minimumLineSpacing = 0
        
        $0.collectionViewLayout = layout
            
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        
        $0.dataSource = self
        $0.delegate = self
        
        $0.register(
            AutoSlideCollectionViewCell.self,
            forCellWithReuseIdentifier: AutoSlideCollectionViewCell.identifier
        )
    }
    
// MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureLayout()
        autoSlideTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CollectionView

extension AutoSlideView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        autoSlideTexts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AutoSlideCollectionViewCell.identifier,
            for: indexPath
        ) as? AutoSlideCollectionViewCell
        
        cell?.configureCell(autoSlideTexts[indexPath.item])
        return cell ?? UICollectionViewCell()
    }
}

extension AutoSlideView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        nowPage = Int(scrollView.contentOffset.x) / Int(frame.width)
    }
}

// MARK: - Private

private extension AutoSlideView {
    func configureLayout() {
        backgroundColor = UIColor.init(rgb: 0xDBF0FF)
        [
            autoSlideCollectionView
        ].forEach { addSubview($0) }
    
        autoSlideCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /// 3초다마 슬라이드  이동
    func autoSlideTimer() {
        let _ = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(autoSlideMove),
            userInfo: nil,
            repeats: true
        )
    }
    
// MARK: - Selector
    
    /// autoSlide Cell를 움직인다.
    @objc func autoSlideMove() {
        // 마지막 페이지이면 맨 처음 페이지로 돌아감
        if nowPage == autoSlideTexts.count - 1 {
            autoSlideCollectionView.scrollToItem(
                at: IndexPath(item: 0, section: 0),
                at: .left,
                animated: true
            )
            #warning("TODO")// TODO: animation 자연스럽게
            nowPage = 0
            
            return
        } else {
            nowPage += 1
            autoSlideCollectionView.scrollToItem(
                at: IndexPath(
                    item: nowPage, section: 0),
                at: .right,
                animated: true
            )
        }
        
    }
}
