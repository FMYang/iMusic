//
//  SwiftyLRC.swift
//  SwiftyRegex
//
//  Created by Roy Tang on 24/6/15.
//  Copyright © 2015 Roy Tang. All rights reserved.
//

import Foundation
import AVFoundation

struct LRCLine {
    var time: CMTime
    var text: String
}

class LRCParse {
        
    static func timeStampToTime(timeStamp: String) -> CMTime {
        
        let str: String = timeStamp.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let tmp: [String] = str.components(separatedBy: ":")
        
        return CMTimeMakeWithSeconds(Float64(tmp[0].floatValue() * 60.0 + tmp[1].floatValue()), preferredTimescale: 600)
    }
    
    static func parse(content: String) -> [LRCLine] {
        let array: [String] = content.components(separatedBy: "\n")
        var lrc: [LRCLine] = []
        
        do {
            for val in array {
                let chomp: String = val.replacingOccurrences(of: "\r", with: "")
                
                let regex = try NSRegularExpression(pattern: "\\[\\d{2}:\\d{2}.\\d{2}\\]", options: NSRegularExpression.Options.caseInsensitive)
                
                let matches = regex.matches(in: chomp, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, chomp.count))
                
                if matches.count > 0 {
                    
                    // find the lyrics str first
                    let last = matches.last! as NSTextCheckingResult
                    
                    let line = (chomp as NSString).substring(
                        with: NSMakeRange(last.range.location + last.range.length, chomp.count - (last.range.location + last.range.length))
                    )
                    
                    for match in matches {
                        let temp = (chomp as NSString).substring(with: match.range)
                        let time = self.timeStampToTime(timeStamp: temp)
                        let model = LRCLine(time: time, text: line)
                        lrc.append(model)
                    }
                }
                
            }
            
            lrc.sort { left, right in
                return CMTimeCompare(left.time, right.time) == -1
            }
                        
            return lrc
        } catch _ {
            return []
        }
    }
    
    static func formatCMTime(_ time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


extension String {
    func floatValue() -> Float {
        return (self as NSString).floatValue
    }
}

typealias LRCTuple = (start: String, end: String)
