//
//  String+Extension.swift
//  iMusic
//
//  Created by yfm on 2023/11/23.
//

import Foundation

extension String {
    static func format(time: Float) -> String {
        let totalSeconds = time
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
