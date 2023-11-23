//
//  Song.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import Foundation

struct Song: Codable {
    var song_name: String
    var play_url: String
    var timelength: Int
    var filesize: Int
    var author_name: String
    var is_free_part: Int
    var img: String
    var album_audio_id: Int64
    var lrc: String
}
