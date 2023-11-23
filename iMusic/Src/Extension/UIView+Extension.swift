//
//  UIView+Extension.swift
//  FMAccountBook
//
//  Created by yfm on 2023/3/15.
//

import UIKit

extension UIView {
    var zy_x: CGFloat {
        
        get {
            
            return self.frame.origin.x
        }
        set(zy_x) {
        
            let y = self.frame.origin.y
            let width = self.frame.size.width
            let height = self.frame.size.height
            self.frame = CGRectMake(zy_x, y, width, height)
        }
    }
    
    var zy_y: CGFloat {
        
        get {
            
            return self.frame.origin.y
        }
        set(zy_y) {
            
            let x = self.frame.origin.x
            let width = self.frame.size.width
            let height = self.frame.size.height
            self.frame = CGRectMake(x, zy_y, width, height)
        }
    }
    
    var zy_width: CGFloat {
        
        get {
            
            return self.frame.size.width
        }
        set(zy_width) {
            
            var frame = self.frame
            frame.size.width = zy_width
            self.frame = frame
        }
    }
    
    var zy_height: CGFloat {
        
        get {
            
            return self.frame.size.height
        }
        set(zy_height) {
            
            var frame = self.frame
            frame.size.height = zy_height
            self.frame = frame
        }
    }
    
    var zy_left: CGFloat {
        
        get {
            return self.frame.origin.x
        }
        set(zy_left) {
            
            let y = self.frame.origin.y
            let width = self.frame.size.width
            let height = self.frame.size.height
            self.frame = CGRectMake(zy_left, y, width, height)
        }
    }
    
    var zy_top: CGFloat {
        
        get {
            
            return self.frame.origin.y
        }
        set(zy_top) {
            
            let x = self.frame.origin.x
            let width = self.frame.size.width
            let height = self.frame.size.height
            self.frame = CGRectMake(x, zy_top, width, height)
        }
    }
    
    var zy_right: CGFloat {
        
        get {
            
            return self.frame.origin.x + self.frame.size.width
        }
        set(zy_right) {
            
            var frame = self.frame
            frame.origin.x = zy_right - frame.size.width
            self.frame = frame
        }
    }
    
    var zy_bottom: CGFloat {
        
        get {
            
            return self.frame.origin.y + self.frame.size.height
        }
        set(zy_bottom) {
            
            var frame = self.frame
            frame.origin.y = zy_bottom - frame.size.height
            self.frame = frame
        }
    }
    
    var zy_size: CGSize {
        
        get {
            
            return self.frame.size
        }
        set(zy_size) {
            
            var frame = self.frame
            frame.size = zy_size
            self.frame = frame
        }
    }
    
    var zy_centerX: CGFloat {
        
        get {
            
            return self.center.x
        }
        set(zy_centerX) {
            
            self.center = CGPointMake(zy_centerX, self.center.y)
        }
    }
    
    
    var zy_centerY: CGFloat {
        
        get {
            
            return self.center.y
        }
        set(zy_centerY) {
            
            self.center = CGPointMake(self.center.x, zy_centerY)
        }
    }
}
