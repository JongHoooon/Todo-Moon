//
//  BaseViewController.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Rx
    
    var disposeBag = DisposeBag()
    
    // MARK: - Layout Constraints
    
    private(set) var didSetupConstrains = false
    
    // TODO: setNeedsUpdateConstraints() 공부
    override func viewDidLoad() {
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = .systemBackground
    }
    
    override func updateViewConstraints() {
        if !self.didSetupConstrains {
            self.setupConstraints()
            self.didSetupConstrains = true
        }
        super.updateViewConstraints()
    }
    
    func setupConstraints() {
        // Override point
    }
}
