//
//  Song.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import Foundation

// 歌曲信息
class Song: Codable, Equatable {
    var song_name: String = ""
    var play_url: String = ""
    var timelength: Int = 0
    var filesize: Int = 0
    var author_name: String = ""
    var is_free_part: Int = 0
    var img: String = ""
    var album_audio_id: Int64 = 0
    var lrc: String = ""
    var isCollect: Bool = false
    
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
    
    // 用于判断对象是否相等（删除时需要）
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.album_audio_id == rhs.album_audio_id
    }
}

// 歌手
class Singer: Codable {
    var singername: String = ""
    var imgurl: String = ""
    var songcount: Int = 0
    var singerid: UInt32 = 0
}

// 歌手列表歌曲
class ListSong: Codable {
    var data: ListData?
}

class ListData: Codable {
    var info: [SongInfo] = []
}

class SongInfo: Codable {
    var filename: String = ""
}
