//
//  Song.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import Foundation

class Song: Codable {
    var song_name: String = ""
    var play_url: String = ""
    var timelength: Int = 0
    var filesize: Int = 0
    var author_name: String = ""
    var is_free_part: Int = 0
    var img: String = ""
    var album_audio_id: Int64 = 0
    var lrc: String = ""
    
    // ignore the key
    var selected: Bool = false
    
    enum CodingKeys: CodingKey {
        case song_name
        case play_url
        case timelength
        case filesize
        case author_name
        case is_free_part
        case img
        case album_audio_id
        case lrc
    }
}
