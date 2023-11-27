//
//  Marco.swift
//  FMAccountBook
// 
//  Created by yfm on 2023/3/8.
//

import UIKit

public let kScreenWidth = UIScreen.main.bounds.size.width
public let kScreenHeight = UIScreen.main.bounds.size.height

public let kSafeAreaInsets: UIEdgeInsets = {
    if #available(iOS 13.0, *) {
        if let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
            return window.safeAreaInsets
        }
    } else {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow}) {
            return window.safeAreaInsets
        }
    }
    return UIEdgeInsets.zero
}()
