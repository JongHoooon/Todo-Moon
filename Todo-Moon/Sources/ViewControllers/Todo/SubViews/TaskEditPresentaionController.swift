//
//  TaskEditPresentaionController.swift
//  HongikTimer
//
//  Created by JongHoon on 2022/10/11.
//

import UIKit
import Alamofire

final class TaskEditPresentaionController: UIPresentationController {
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissController)
        )
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(
            origin: CGPoint(
                x: 0,
                y: containerView!.frame.height * 0.5
            ),
            size: CGSize(
                width: containerView!.frame.width,
                height: containerView!.frame.height * 0.5
            )
        )
    }
    
    // 프레임 설정
    override func presentationTransitionWillBegin() {
        blurEffectView.alpha = 0
        containerView?.addSubview(blurEffectView)
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: { [weak self] _ in
            self?.blurEffectView.alpha = 0.5
        }, completion: { _ in })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: { [weak self] _ in
            self?.blurEffectView.alpha = 0
        }, completion: {[ weak self] _ in
            self?.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 22)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismissController() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
