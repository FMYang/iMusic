//
//  ScrollingLabel.swift
//  iMusic
//
//  Created by yfm on 2023/11/22.
//

import UIKit

class ScrollingLabel: UIView, UIScrollViewDelegate {
        
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    var text: String = "" {
        didSet {
            textLabel.text = text
            let size = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            let width = max(size.width, frame.size.width)

            scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            scrollView.contentSize = CGSize(width: width, height: frame.size.height)

            textLabel.frame = CGRect(x: 0, y: 0, width: size.width, height: frame.size.height)

            if size.width < frame.size.width {
                textLabel.textAlignment = .left
                endAnimation()
            } else {
//                startAnimation()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func startAnimation() {
        endAnimation()
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 5.0
        animation.repeatCount = .greatestFiniteMagnitude
        animation.fromValue = 10
        animation.toValue = -(textLabel.bounds.width - frame.width)
        textLabel.layer.add(animation, forKey: "positionAnimation")
    }
    
    func endAnimation() {
        textLabel.transform = CGAffineTransformIdentity
        textLabel.layer.removeAllAnimations()
    }
}
