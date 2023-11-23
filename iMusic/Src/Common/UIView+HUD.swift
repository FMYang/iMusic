//
//  UIView+HUD.swift
//  iGithub
//
//  Created by yfm on 2019/1/18.
//  Copyright © 2019年 com.yfm.www. All rights reserved.
//

import Foundation
import MBProgressHUD

private var hudKey: Int = 0

extension UIView {
    
    func showLoading(_ title: String?) {
        if let text = title {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            ig_hud = hud
            hud.bezelView.style = .solidColor
            hud.bezelView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            hud.mode = .customView
            hud.bezelView.blurEffectStyle = .light
            hud.contentColor = .white
            hud.label.text = text
            hud.removeFromSuperViewOnHide = true
        }
    }

    func hideLoading() {
        guard let hud = ig_hud else { return }
        hud.hide(animated: true, afterDelay: 0.25)
    }

    func hideWithMessage(title: String) {
        guard let hud = ig_hud else { return }
        hud.mode = .text
        hud.label.text = title
        hud.hide(animated: true, afterDelay: 2)
    }

    func showToast(_ title: String?) {
        if let text = title {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = .text
            hud.label.text = text
            hud.label.textColor = .white
            hud.label.font = .systemFont(ofSize: 14)
            hud.bezelView.style = .solidColor
            hud.bezelView.blurEffectStyle = .light
            hud.bezelView.backgroundColor = .black.withAlphaComponent(0.6)
            hud.hide(animated: true, afterDelay: 2.0)
            hud.margin = 10.0
            hud.removeFromSuperViewOnHide = true
        }
    }

    var ig_hud: MBProgressHUD? {
        get {
            return objc_getAssociatedObject(self, &hudKey) as? MBProgressHUD
        }
        set {
            objc_setAssociatedObject(self, &hudKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
