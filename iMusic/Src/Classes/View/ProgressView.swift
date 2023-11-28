//
//  ProgressView.swift
//  iMusic
//
//  Created by yfm on 2023/11/28.
//

import UIKit

class ProgressView: UIView {
    
    lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        return layer
    }()
    
    lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.withAlphaComponent(0.9).cgColor
        return layer
    }()
    
    var progress: CGFloat = 0.0 {
        didSet {
            if progress <= 0.0 { progress = 0.0 }
            if progress >= 1.0 { progress = 1.0 }
            let w = progress * bounds.size.width
            let path = UIBezierPath(roundedRect: CGRectMake(0, 0, w, bounds.size.height), cornerRadius: bounds.size.height / 2)
            progressLayer.path = path.cgPath
        }
    }
    
    var trackColor: UIColor = .black.withAlphaComponent(0.2) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progressColor: UIColor = .black {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        trackLayer.cornerRadius = bounds.size.height / 2
        progressLayer.cornerRadius = bounds.size.height / 2
        trackLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.height / 2).cgPath
    }
}
