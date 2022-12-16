//
//  CategoryView.swift
//  10-2-home
//
//  Created by JongHoon on 2022/10/15.
//

import Then
import SnapKit
import UIKit

final class CategoryView: UIView {
  
  private let titles: [(
    text: String,
    image: UIImage?
  )] = [
    ("전체", UIImage(named: "title1")),
    ("평일 스터디", UIImage(named: "title2")),
    ("주말 스터디", UIImage(named: "title3")),
    ("주간 스터디", UIImage(named: "title4")),
    ("인기", UIImage(named: "title5")),
    ("인기", UIImage(named: "title5")),
    ("인기", UIImage(named: "title5"))
  ]
  
  private lazy var categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(
      top: 16.0,
      left: 16.0,
      bottom: 0,
      right: 16.0
    )
#warning("왼쪽 inset")
    layout.scrollDirection = .horizontal
    $0.collectionViewLayout = layout
    
    
    $0.showsHorizontalScrollIndicator = false
    $0.dataSource = self
    $0.delegate = self
    
    $0.register(
      CategoryCollectionViewCell.self,
      forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
    )
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

// MARK: - CollectionView

extension CategoryView: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return titles.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: CategoryCollectionViewCell.identifier,
      for: indexPath
    ) as? CategoryCollectionViewCell
    
    let title = titles[indexPath.item]
    
    cell?.configureCell(title.image!, title.text)
    
    return cell ?? UICollectionViewCell()
  }
}

extension CategoryView: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: 60.0, height: 96.0)
  }
}


// MARK: - Private

private extension CategoryView {
  func configureLayout() {
    [
      categoryCollectionView
    ].forEach { addSubview($0) }
    
    categoryCollectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

